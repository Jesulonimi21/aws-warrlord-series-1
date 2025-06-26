# Best Practices
1. Use Locking(explain why)
2. Use a backend.hcl file for joint file or module configuratiins
3. Make sure workspaces change when a different version is checked out(use git hooks)
4. Use an Outputs.tf file and a vars.tf file
5. Use prevent_destroy where necessary
6. Use create_before_destroy where necessary
7. Use Data to read secrets
8. Use Modules for different portions of your terraform config
9. Use locals for variables that you want resused but you do not want passed into your modules
10. Don't hardcode directories, use path instead
11. Use resources instead of inline blocks
12. Run tests and production stages in different vpcs using modules
13. Use versioning of modules for different stages for production and staging 