ExUnit.start(max_cases: 10)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, DemoWeb.Endpoint.url())
