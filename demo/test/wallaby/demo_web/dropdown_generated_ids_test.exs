defmodule DemoWeb.DropdownGeneratedIdsTest do
  use Prima.WallabyCase, async: true

  @root "#generated-dropdown"
  @trigger Query.css("#{@root} [aria-haspopup=menu]")

  feature "generated IDs and ARIA relationships survive a keyed removal and insertion", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown-generated-ids", @root)
    |> click(@trigger)
    |> assert_relationships()
    |> execute_script("""
      const section = document.querySelector('[data-section="Banana"]');
      window.retainedItem = section.querySelector('[role=menuitem]');
      window.retainedHeading = section.querySelector('[role=presentation]');
      window.retainedIds = [window.retainedItem.id, window.retainedHeading.id];
    """)
    |> click(Query.css("#update-items"))
    |> click(@trigger)
    |> assert_has(Query.css("#{@root} [data-item=Cherry]"))
    |> assert_missing(Query.css("#{@root} [data-item=Apple]"))
    |> execute_script(
      """
      const section = document.querySelector('[data-section="Banana"]');
      const item = section.querySelector('[role=menuitem]');
      const heading = section.querySelector('[role=presentation]');
      return item === window.retainedItem && heading === window.retainedHeading &&
        item.id === window.retainedIds[0] && heading.id === window.retainedIds[1];
      """,
      fn preserved -> assert preserved end
    )
    |> assert_relationships()
    |> send_keys([:down_arrow, :down_arrow])
    |> assert_has(Query.css("#{@root} [data-item=Cherry][data-focus]"))
    |> execute_script(
      """
      const menu = document.querySelector('#generated-dropdown [role=menu]');
      const active = document.getElementById(menu.getAttribute('aria-activedescendant'));
      return active && active.dataset.item === 'Cherry';
      """,
      fn correct_item -> assert correct_item end
    )
  end

  defp assert_relationships(session) do
    execute_script(
      session,
      """
      const root = document.querySelector('#generated-dropdown');
      const trigger = root.querySelector('[aria-haspopup=menu]');
      const menu = root.querySelector('[role=menu]');
      const items = [...root.querySelectorAll('[role=menuitem]')];
      const sections = [...root.querySelectorAll('[role=group]')];
      const ids = [...document.querySelectorAll('[id]')].map(el => el.id);
      return new Set(ids).size === ids.length &&
        items.every(item => item.id) &&
        trigger.getAttribute('aria-controls') === menu.id &&
        menu.getAttribute('aria-labelledby') === trigger.id &&
        sections.every(section =>
          document.getElementById(section.getAttribute('aria-labelledby')) ===
            section.querySelector('[role=presentation]')) &&
        document.getElementById('generated-dropdown-item-1-1').dataset.item === 'Custom' &&
        document.getElementById('generated-dropdown-section-1-heading-1').textContent.trim() === 'Custom';
      """,
      fn valid -> assert valid end
    )
  end
end
