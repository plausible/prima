defmodule DemoWeb.PopoverLifecycleTest do
  use Prima.WallabyCase, async: true

  for kind <- ["dropdown", "listbox", "combobox"] do
    @kind kind
    @root "#popover-#{kind}"
    @trigger "#popover-#{kind}-trigger-0"
    @panel "#popover-#{kind}-panel-0"
    @patched_focus "#popover-#{kind}-#{if kind == "combobox", do: "trigger", else: "panel"}-1"

    feature "#{@kind} closes logically before its exit animation finishes", %{session: session} do
      session
      |> open_popup(@kind, true)
      |> execute_script(
        """
        const trigger = document.querySelector('#{@trigger}');
        const panel = document.querySelector('#{@panel}');
        document.activeElement.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true}));
        return {
          expanded: trigger.getAttribute('aria-expanded'),
          inert: panel.inert,
          ariaHidden: panel.getAttribute('aria-hidden'),
          wrapperVisible: panel.parentElement.style.display !== 'none',
          triggerFocused: document.activeElement === trigger,
          activeOption: document.querySelector('#{@root} [data-focus]') !== null
        };
        """,
        fn result ->
          assert result == %{
                   "expanded" => "false",
                   "inert" => true,
                   "ariaHidden" => "true",
                   "wrapperVisible" => true,
                   "triggerFocused" => true,
                   "activeOption" => false
                 }
        end
      )
      |> assert_has(Query.css("#{@panel}[data-hides='1']", visible: false))
    end

    feature "#{@kind} can reopen during its exit without stale cleanup", %{session: session} do
      session
      |> open_popup(@kind, true)
      |> execute_script("""
      const trigger = document.querySelector('#{@trigger}');
      document.activeElement.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true}));
      trigger.click();
      """)
      |> assert_has(Query.css("#{@trigger}[aria-expanded=true]"))
      |> assert_has(Query.css("#{@panel}[data-hides='1']:not([inert]):not([aria-hidden])"))
      |> execute_script("""
      const input = document.querySelector('#popover-refresh');
      input.value = 'patch';
      input.dispatchEvent(new Event('input', {bubbles: true}));
      """)
      |> assert_has(Query.css("#{@root}[data-patch='1']"))
      |> assert_has(Query.css("#{@panel}:not([inert])"))
      |> send_keys([:escape])
      |> assert_has(Query.css("#{@panel}[data-hides='2']", visible: false))
      |> assert_has(Query.css("#{@trigger}:focus[aria-expanded=false]"))
    end

    feature "#{@kind} honors close-open-close during an unfinished transition", %{
      session: session
    } do
      session
      |> open_popup(@kind, true)
      |> execute_script("""
      const trigger = document.querySelector('#{@trigger}');
      const escape = () => document.activeElement.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true}));
      escape();
      trigger.click();
      escape();
      """)
      |> assert_has(Query.css("#{@panel}[data-hides][inert]", visible: false))
      |> assert_has(Query.css("#{@trigger}:focus[aria-expanded=false]"))
    end

    feature "#{@kind} closes before its first show completes", %{session: session} do
      session
      |> visit_fixture("/fixtures/popover-lifecycle?animated=true", @root)
      |> watch_transitions(@panel)
      |> execute_script("""
      const trigger = document.querySelector('#{@trigger}');
      trigger.focus();
      trigger.click();
      trigger.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true}));
      """)
      |> assert_has(Query.css("#{@trigger}[aria-expanded=false]"))
      |> assert_has(Query.css("#{@panel}[data-shows='1'][inert]", visible: false))
    end

    feature "#{@kind} closes without an exit animation", %{session: session} do
      session
      |> open_popup(@kind, false)
      |> send_keys([:escape])
      |> assert_has(Query.css("#{@trigger}:focus[aria-expanded=false]"))
      |> assert_has(Query.css(@panel, visible: false))
    end

    feature "#{@kind} preserves outside focus on dismissal", %{session: session} do
      session
      |> open_popup(@kind, true)
      |> click(Query.css("#after-#{@kind}"))
      |> assert_has(Query.css("#{@panel}[data-hides='1']", visible: false))
      |> assert_has(Query.css("#after-#{@kind}:focus"))
    end

    feature "#{@kind} follows layout changes while open", %{session: session} do
      session
      |> open_popup(@kind, false)
      |> execute_script("""
      const trigger = document.querySelector('#{@trigger}');
      const panel = document.querySelector('#{@panel}');
      const wrapper = panel.parentElement;
      wrapper.dataset.placement = 'bottom-start';
      wrapper.dataset.flip = 'false';
      wrapper.dataset.offset = '0';
      let frame;
      const check = () => {
        const anchor = trigger.getBoundingClientRect();
        const popup = wrapper.getBoundingClientRect();
        if (Math.abs(popup.left - anchor.left) < 1 && Math.abs(popup.top - anchor.bottom) < 1) {
          panel.dataset.repositioned = 'true';
        } else {
          frame = requestAnimationFrame(check);
        }
      };
      panel.addEventListener('phx:hide-end', () => cancelAnimationFrame(frame), {once: true});
      trigger.style.marginLeft = '30px';
      trigger.style.height = '60px';
      frame = requestAnimationFrame(check);
      """)
      |> assert_has(Query.css("#{@panel}[data-repositioned=true]"))
      |> send_keys([:escape])
      |> assert_has(Query.css(@panel, visible: false))
    end

    feature "#{@kind} prevents focus entering the panel during exit", %{session: session} do
      session
      |> open_popup(@kind, true)
      |> execute_script(
        """
        const option = document.querySelector('#{@panel} [role=#{if @kind == "dropdown", do: "menuitem", else: "option"}]');
        option.tabIndex = -1;
        document.activeElement.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true}));
        option.focus();
        return document.activeElement === document.querySelector('#{@trigger}');
        """,
        fn trigger_focused -> assert trigger_focused end
      )
    end

    feature "#{@kind} dismisses when focus moves outside without a click", %{session: session} do
      session
      |> open_popup(@kind, false)
      |> execute_script("document.querySelector('#after-#{@kind}').focus();")
      |> assert_has(Query.css("#{@trigger}[aria-expanded=false]"))
      |> assert_has(Query.css("#after-#{@kind}:focus"))
      |> assert_has(Query.css(@panel, visible: false))
    end

    feature "#{@kind} permits focus and selection inside the panel", %{session: session} do
      session
      |> open_popup(@kind, false)
      |> execute_script("""
      const option = document.querySelector('#{@panel} [role=#{if @kind == "dropdown", do: "menuitem", else: "option"}]');
      option.tabIndex = -1;
      option.focus();
      """)
      |> assert_has(Query.css("#{@trigger}[aria-expanded=true]"))
      |> execute_script("document.activeElement.click();")
      |> assert_has(Query.css("#{@trigger}:focus[aria-expanded=false]"))
    end

    feature "#{@kind} lets Tab and Shift+Tab move outside", %{session: session} do
      session
      |> open_popup(@kind, false)
      |> send_keys([:tab])
      |> assert_has(Query.css("#after-#{@kind}:focus"))
      |> assert_has(Query.css(@panel, visible: false))
      |> click(Query.css(@trigger))
      |> assert_has(Query.css("#{@panel}[data-shows='2']"))
      |> send_keys([:shift, :tab, :null])
      |> assert_has(Query.css("#before-#{@kind}:focus"))
      |> assert_has(Query.css(@panel, visible: false))
    end

    feature "#{@kind} rebinds replaced elements during a LiveView patch", %{session: session} do
      session
      |> open_popup(@kind, false)
      |> execute_script("""
      const input = document.querySelector('#popover-refresh');
      input.value = 'refresh';
      input.dispatchEvent(new Event('input', {bubbles: true}));
      """)
      |> assert_has(Query.css("#popover-#{@kind}-panel-1", visible: :any))
      |> assert_has(Query.css("#popover-#{@kind}-panel-1:not([inert])"))
      |> assert_has(Query.css("#popover-#{@kind}-trigger-1[aria-expanded=true]"))
      |> assert_has(Query.css("#{@patched_focus}:focus"))
      |> click(Query.css("#popover-#{@kind}-trigger-1"))
      |> assert_has(Query.css("#popover-#{@kind}-panel-1", visible: false))
      |> click(Query.css("#popover-#{@kind}-trigger-1"))
      |> assert_has(Query.css("#popover-#{@kind}-panel-1:not([inert])"))
      |> click(Query.css("#after-#{@kind}"))
      |> assert_has(Query.css("#popover-#{@kind}-panel-1", visible: false))
    end
  end

  feature "Tab discards a create query without creating an option", %{session: session} do
    session
    |> open_popup("combobox", false)
    |> fill_in(Query.css("#popover-combobox-trigger-0"), with: "New fruit")
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#popover-combobox [data-prima-ref=create-option][data-focus=true]"))
    |> send_keys([:tab])
    |> assert_has(Query.css("#after-combobox:focus"))
    |> assert_has(Query.css("#popover-combobox-panel-0", visible: false))
    |> execute_script(
      """
      return {
        search: document.querySelector('#popover-combobox-trigger-0').value,
        selected: document.querySelector('#popover-combobox select').selectedOptions.length
      };
      """,
      fn result -> assert result == %{"search" => "", "selected" => 0} end
    )
  end

  defp open_popup(session, kind, animated) do
    session
    |> visit_fixture("/fixtures/popover-lifecycle?animated=#{animated}", "#popover-#{kind}")
    |> watch_transitions("#popover-#{kind}-panel-0")
    |> click(Query.css("#popover-#{kind}-trigger-0"))
    |> assert_has(Query.css("#popover-#{kind}-panel-0[data-shows='1']"))
  end

  defp watch_transitions(session, panel) do
    execute_script(session, """
    const panel = document.querySelector('#{panel}');
    let shows = 0;
    let hides = 0;
    panel.addEventListener('phx:show-end', () => { panel.dataset.shows = ++shows });
    panel.addEventListener('phx:hide-end', () => { panel.dataset.hides = ++hides });
    """)
  end
end
