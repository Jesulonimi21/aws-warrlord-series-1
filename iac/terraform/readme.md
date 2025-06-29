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
14. # Deploy only from ci/cd so that there is never a conflicting deployment
15. Come up with a tagging standard(this also makes sure people know what resources to edit by hand and what resources they should not)
16. # You can set resource names to depend on each other so that when one changes, the other also gets destroyed and changed as well
17. limitations for count, for_each and for, zero downtime deployments
18. Be careful with renaming resources during refactoring
19. Zero downtime: using create_before_destroy and creating the resource manually with apply, then remove the old resource and then link the new resource
20. wHEN ALL you change is unique identifiers and you do not want to destroy resources, you need to use the terraform state mv command





For destroying a terraform config that uses a remote backend for state management, you want to first go back to using a locla backend by using terraform init, thenrunning destry so that the 3 bucket can also be deleted




# Master 
- Zero Downtime deployment on aws even with terraform