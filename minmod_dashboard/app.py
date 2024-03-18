import dash_bootstrap_components as dbc
import dash

app = dash.Dash(external_stylesheets=[dbc.themes.LITERA], use_pages=True)

app.layout = dash.html.Div(
    [
        dbc.Row(
            dbc.Nav(
                [
                    dbc.NavItem(dbc.NavLink("Dashboard", active=True, href="/")),
                    dbc.NavItem(
                        dbc.NavLink(
                            "Mineral Inventory", active=True, href="mineralinventory"
                        )
                    ),
                    dbc.NavItem(
                        dbc.NavLink("SPARQL Sandbox", active=True, href="sparql")
                    ),
                ]
            )
        ),
        dash.page_container,
    ]
)

# Run app and display result inline in the notebook
if __name__ == "__main__":
    app.run_server(host="0.0.0.0", port=8050)
