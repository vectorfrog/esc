# Tree Styles Demo
# Run with: mix run examples/tree_demo.exs

alias Esc.Tree
import Esc

IO.puts("\n=== Esc Tree Styles Demo ===\n")

# 1. Enumerator styles
IO.puts("1. Enumerator Styles:\n")

IO.puts("   Default (└──):")
tree =
  Tree.root("project")
  |> Tree.child("src")
  |> Tree.child("lib")
  |> Tree.child("test")
  |> Tree.enumerator(:default)
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("   Rounded (╰──):")
tree =
  Tree.root("project")
  |> Tree.child("src")
  |> Tree.child("lib")
  |> Tree.child("test")
  |> Tree.enumerator(:rounded)
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 2. Root styling
IO.puts("2. Root Styling:\n")

root_styles = [
  {"Bold", style() |> bold()},
  {"Cyan", style() |> foreground(:cyan)},
  {"Bold yellow on blue", style() |> bold() |> foreground(:yellow) |> background(:blue)}
]

for {label, root_style} <- root_styles do
  IO.puts("   #{label}:")

  tree =
    Tree.root("~/Documents")
    |> Tree.child("notes.txt")
    |> Tree.child("todo.md")
    |> Tree.enumerator(:rounded)
    |> Tree.root_style(root_style)
    |> Tree.render()

  tree
  |> String.split("\n")
  |> Enum.each(&IO.puts("   #{&1}"))

  IO.puts("")
end

# 3. Item styling
IO.puts("3. Item Styling:\n")

tree =
  Tree.root("Colors")
  |> Tree.child("Red file")
  |> Tree.child("Green file")
  |> Tree.child("Blue file")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:white))
  |> Tree.item_style(style() |> foreground(:green))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 4. Enumerator styling (connector colors)
IO.puts("4. Enumerator Styling (colored connectors):\n")

connector_styles = [
  {"Yellow connectors", style() |> foreground(:yellow)},
  {"Dim connectors", style() |> faint()},
  {"Cyan connectors", style() |> foreground(:cyan)}
]

for {label, enum_style} <- connector_styles do
  IO.puts("   #{label}:")

  tree =
    Tree.root("Root")
    |> Tree.child("Branch A")
    |> Tree.child("Branch B")
    |> Tree.child("Branch C")
    |> Tree.enumerator(:rounded)
    |> Tree.root_style(style() |> bold())
    |> Tree.enumerator_style(enum_style)
    |> Tree.render()

  tree
  |> String.split("\n")
  |> Enum.each(&IO.puts("   #{&1}"))

  IO.puts("")
end

# 5. Nested trees
IO.puts("5. Nested Trees:\n")

subtree1 =
  Tree.root("src")
  |> Tree.child("main.ex")
  |> Tree.child("utils.ex")

subtree2 =
  Tree.root("test")
  |> Tree.child("main_test.exs")

tree =
  Tree.root("my_app")
  |> Tree.child(subtree1)
  |> Tree.child(subtree2)
  |> Tree.child("mix.exs")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:blue))
  |> Tree.item_style(style() |> foreground(:white))
  |> Tree.enumerator_style(style() |> foreground(:yellow))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 6. Deep nesting
IO.puts("6. Deep Nesting:\n")

deep_subtree =
  Tree.root("deeply")
  |> Tree.child(
    Tree.root("nested")
    |> Tree.child(
      Tree.root("structure")
      |> Tree.child("leaf.txt")
    )
  )

tree =
  Tree.root("root")
  |> Tree.child(deep_subtree)
  |> Tree.child("sibling")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold())
  |> Tree.enumerator_style(style() |> foreground(:cyan))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 7. File system style
IO.puts("7. File System Style:\n")

lib =
  Tree.root("lib/")
  |> Tree.child("esc.ex")
  |> Tree.child(
    Tree.root("esc/")
    |> Tree.child("border.ex")
    |> Tree.child("color.ex")
    |> Tree.child("style.ex")
    |> Tree.child("table.ex")
    |> Tree.child("tree.ex")
  )

test =
  Tree.root("test/")
  |> Tree.child("esc_test.exs")
  |> Tree.child("test_helper.exs")

tree =
  Tree.root("esc/")
  |> Tree.child(lib)
  |> Tree.child(test)
  |> Tree.child("mix.exs")
  |> Tree.child("README.md")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:blue))
  |> Tree.item_style(style() |> foreground(:white))
  |> Tree.enumerator_style(style() |> faint())
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 8. Combined styling showcase
IO.puts("8. Full Styling Showcase:\n")

apps =
  Tree.root("Applications")
  |> Tree.child("Terminal")
  |> Tree.child("Editor")
  |> Tree.child("Browser")

docs =
  Tree.root("Documents")
  |> Tree.child("Projects")
  |> Tree.child("Notes")

tree =
  Tree.root("~")
  |> Tree.child(apps)
  |> Tree.child(docs)
  |> Tree.child(".config")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:magenta))
  |> Tree.item_style(style() |> foreground(:green))
  |> Tree.enumerator_style(style() |> foreground(:yellow))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 9. Dependency tree (npm/mix style)
IO.puts("9. Dependency Tree:\n")

phoenix_deps =
  Tree.root("phoenix@1.7.10")
  |> Tree.child("plug@1.15.2")
  |> Tree.child("phoenix_html@3.3.3")

ecto_deps =
  Tree.root("ecto@3.11.1")
  |> Tree.child("decimal@2.1.1")
  |> Tree.child("jason@1.4.1")

tree =
  Tree.root("my_app@0.1.0")
  |> Tree.child(phoenix_deps)
  |> Tree.child(ecto_deps)
  |> Tree.child("telemetry@1.2.1")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:green))
  |> Tree.item_style(style() |> foreground(:cyan))
  |> Tree.enumerator_style(style() |> faint())
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 10. Process tree (pstree style)
IO.puts("10. Process Tree:\n")

bash_procs =
  Tree.root("bash (1234)")
  |> Tree.child("vim (1240)")
  |> Tree.child("mix run (1245)")

nginx_procs =
  Tree.root("nginx (890)")
  |> Tree.child("nginx worker (891)")
  |> Tree.child("nginx worker (892)")
  |> Tree.child("nginx worker (893)")

tree =
  Tree.root("systemd (1)")
  |> Tree.child(bash_procs)
  |> Tree.child(nginx_procs)
  |> Tree.child("postgres (456)")
  |> Tree.child("redis-server (789)")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:yellow))
  |> Tree.item_style(style() |> foreground(:white))
  |> Tree.enumerator_style(style() |> foreground(:blue))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 11. File browser with icons
IO.puts("11. File Browser with Icons:\n")

src_folder =
  Tree.root("📁 src")
  |> Tree.child("📄 main.ex")
  |> Tree.child("📄 router.ex")
  |> Tree.child("📄 endpoint.ex")

assets_folder =
  Tree.root("📁 assets")
  |> Tree.child("🖼️  logo.png")
  |> Tree.child("📄 app.css")
  |> Tree.child("📄 app.js")

tree =
  Tree.root("📁 my_project")
  |> Tree.child(src_folder)
  |> Tree.child(assets_folder)
  |> Tree.child("📄 README.md")
  |> Tree.child("⚙️  mix.exs")
  |> Tree.child("🔒 .env")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold())
  |> Tree.enumerator_style(style() |> faint())
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 12. Status/health tree (monitoring dashboard)
IO.puts("12. Service Health Tree:\n")

api_services =
  Tree.root("🌐 API Gateway")
  |> Tree.child("✅ auth-service (healthy)")
  |> Tree.child("✅ user-service (healthy)")
  |> Tree.child("⚠️  payment-service (degraded)")

db_services =
  Tree.root("💾 Databases")
  |> Tree.child("✅ postgres-primary (healthy)")
  |> Tree.child("✅ postgres-replica (healthy)")
  |> Tree.child("❌ redis-cache (down)")

tree =
  Tree.root("🖥️  Production Cluster")
  |> Tree.child(api_services)
  |> Tree.child(db_services)
  |> Tree.child("✅ nginx-lb (healthy)")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:cyan))
  |> Tree.enumerator_style(style() |> foreground(:blue))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 13. JSON/Config structure visualization
IO.puts("13. JSON Structure Visualization:\n")

user_obj =
  Tree.root("user: {}")
  |> Tree.child("id: 123")
  |> Tree.child("name: \"Alice\"")
  |> Tree.child("email: \"alice@example.com\"")

prefs_obj =
  Tree.root("preferences: {}")
  |> Tree.child("theme: \"dark\"")
  |> Tree.child("notifications: true")

address_obj =
  Tree.root("address: {}")
  |> Tree.child("city: \"Austin\"")
  |> Tree.child("zip: \"78701\"")

tree =
  Tree.root("config.json")
  |> Tree.child(user_obj)
  |> Tree.child(prefs_obj)
  |> Tree.child(address_obj)
  |> Tree.child("version: \"1.0.0\"")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:magenta))
  |> Tree.item_style(style() |> foreground(:yellow))
  |> Tree.enumerator_style(style() |> faint())
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 14. Git branch visualization
IO.puts("14. Git Branch Tree:\n")

feature_branches =
  Tree.root("develop")
  |> Tree.child("feature/auth")
  |> Tree.child("feature/payments")
  |> Tree.child("feature/notifications")

release_branches =
  Tree.root("release/v2.0")
  |> Tree.child("hotfix/login-fix")

tree =
  Tree.root("main")
  |> Tree.child(feature_branches)
  |> Tree.child(release_branches)
  |> Tree.child("hotfix/security-patch")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:green))
  |> Tree.item_style(style() |> foreground(:cyan))
  |> Tree.enumerator_style(style() |> foreground(:yellow))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 15. Organization chart
IO.puts("15. Organization Chart:\n")

engineering =
  Tree.root("👩‍💻 VP Engineering")
  |> Tree.child("👨‍💻 Tech Lead - Backend")
  |> Tree.child("👩‍💻 Tech Lead - Frontend")
  |> Tree.child("👨‍💻 Tech Lead - DevOps")

product =
  Tree.root("📊 VP Product")
  |> Tree.child("📋 Product Manager")
  |> Tree.child("🎨 UX Designer")

tree =
  Tree.root("🏢 CEO")
  |> Tree.child(engineering)
  |> Tree.child(product)
  |> Tree.child("💰 CFO")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:yellow))
  |> Tree.enumerator_style(style() |> foreground(:blue))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 16. Menu structure with shortcuts
IO.puts("16. Application Menu:\n")

file_menu =
  Tree.root("File")
  |> Tree.child("New         ⌘N")
  |> Tree.child("Open        ⌘O")
  |> Tree.child("Save        ⌘S")
  |> Tree.child("Close       ⌘W")

edit_menu =
  Tree.root("Edit")
  |> Tree.child("Undo        ⌘Z")
  |> Tree.child("Redo        ⇧⌘Z")
  |> Tree.child("Cut         ⌘X")
  |> Tree.child("Copy        ⌘C")
  |> Tree.child("Paste       ⌘V")

view_menu =
  Tree.root("View")
  |> Tree.child("Zoom In     ⌘+")
  |> Tree.child("Zoom Out    ⌘-")
  |> Tree.child("Full Screen ⌃⌘F")

tree =
  Tree.root("Menu Bar")
  |> Tree.child(file_menu)
  |> Tree.child(edit_menu)
  |> Tree.child(view_menu)
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:white))
  |> Tree.item_style(style() |> foreground(:cyan))
  |> Tree.enumerator_style(style() |> faint())
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("=== Demo Complete ===\n")
