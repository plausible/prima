defmodule DemoWeb.DropdownSectionsTest do
  use Prima.WallabyCase, async: true

  @dropdown_button Query.css("#dropdown-sections [aria-haspopup=menu]")
  @dropdown_menu Query.css("#dropdown-sections [role=menu]")

  feature "renders sections with proper ARIA roles", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-sections", "#dropdown-sections")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(Query.css("#dropdown-sections [role=group]", count: 2))
  end

  feature "renders headings with proper ARIA presentation role", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-sections", "#dropdown-sections")
    |> click(@dropdown_button)
    |> assert_has(Query.css("#dropdown-sections [role=presentation]", count: 2))
  end

  feature "renders separators with proper ARIA role", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-sections", "#dropdown-sections")
    |> click(@dropdown_button)
    |> assert_has(
      Query.css("#dropdown-sections [role=separator]", count: 2)
      |> Query.visible(false)
    )
  end

  feature "generates IDs for section headings and establishes aria-labelledby relationships", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown-sections", "#dropdown-sections")
    |> click(@dropdown_button)
    # Verify that headings have auto-generated IDs following the pattern: {dropdown-id}-section-{index}-heading
    |> assert_has(
      Query.css(
        "#dropdown-sections [role=presentation]#dropdown-sections-section-0-heading",
        count: 1
      )
    )
    |> assert_has(
      Query.css(
        "#dropdown-sections [role=presentation]#dropdown-sections-section-1-heading",
        count: 1
      )
    )
    # Verify that sections have aria-labelledby pointing to the auto-generated heading IDs
    |> assert_has(
      Query.css(
        "#dropdown-sections [role=group][aria-labelledby='dropdown-sections-section-0-heading']",
        count: 1
      )
    )
    |> assert_has(
      Query.css(
        "#dropdown-sections [role=group][aria-labelledby='dropdown-sections-section-1-heading']",
        count: 1
      )
    )
    # Verify the first section's heading ID matches its aria-labelledby and contains correct text
    |> execute_script("""
      const firstSection = document.querySelector('#dropdown-sections [role=group]');
      const labelId = firstSection.getAttribute('aria-labelledby');
      const heading = document.getElementById(labelId);
      return heading &&
             heading.getAttribute('role') === 'presentation' &&
             labelId === 'dropdown-sections-section-0-heading' &&
             heading.textContent.trim().includes('Account');
    """)
    # Verify the second section's heading ID and text
    |> execute_script("""
      const sections = document.querySelectorAll('#dropdown-sections [role=group]');
      const secondSection = sections[1];
      const labelId = secondSection.getAttribute('aria-labelledby');
      const heading = document.getElementById(labelId);
      return heading &&
             heading.getAttribute('role') === 'presentation' &&
             labelId === 'dropdown-sections-section-1-heading' &&
             heading.textContent.trim().includes('Support');
    """)
  end

  feature "keyboard navigation skips headings and separators", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-sections", "#dropdown-sections")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown-sections-item-0[data-focus]"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown-sections-item-1[data-focus]"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown-sections-item-2[data-focus]"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown-sections-item-3[data-focus]"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown-sections-item-4[data-focus]"))
  end

  feature "Home key navigates to first menu item, skipping headings", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-sections", "#dropdown-sections")
    |> click(@dropdown_button)
    |> send_keys([:end])
    |> assert_has(Query.css("#dropdown-sections [role=menuitem]:last-of-type[data-focus]"))
    |> send_keys([:home])
    |> assert_has(Query.css("#dropdown-sections [role=menuitem]:first-of-type[data-focus]"))
  end

  feature "End key navigates to last menu item, skipping separators", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-sections", "#dropdown-sections")
    |> click(@dropdown_button)
    |> send_keys([:home])
    |> assert_has(Query.css("#dropdown-sections [role=menuitem]:first-of-type[data-focus]"))
    |> send_keys([:end])
    |> assert_has(Query.css("#dropdown-sections [role=menuitem]:last-of-type[data-focus]"))
  end
end
