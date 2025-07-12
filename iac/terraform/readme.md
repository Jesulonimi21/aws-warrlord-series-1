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
21. # Large Modules are slow, terraform plan would take a way longer time if all my infra is in one file
22. # Large modules are insecure,anyone working on the infra would need access to so many things
23. # Large modules are difficult to understand, the more code you have in one place, the more difficult it is to understand it all
24. # Any mistake could break everything in a large module
25. # If a module is too large, no one would bother to read it or review it
26. # Large modules are difficult to test
27. # Create example files to test your modules independently(every module should have an example folder)
28. pin your terraform version to a specific version using requires_version
29. pin provider versions too
30. Consider uploading modules to the terraform registry
31. use Terratest
32. Run AUtomated or integrated test suite in a totally separate AWS account, use aws nuke or cloudnuke for this
33. Use conditionals to automate remote state fetching during testing
34. namespace all resources(you can also make sure the name for all resources are optionally configurable)
35. run all tests in parallel
36. Additional reading: test_structure.copyTerraformFolderToTemp
37. test_structure.loadTerraformOptions to save funds and only run specific tests
38. # The Test Pyramid  
39. # Probability tests, do the probability of a test failing
40. # zERO dOWNTIME ROLLING DEPLOYMENTS test
41. tflint, terraform validate
42. # Rather than what terraform can do. focus on what a company can do with terraform
43. # joel test
44. The master branch of the live repository should be a 1 to 1 of what is happening on terraform
45. Add a ore commit hook that runs terraform fmt
46. atlantis adds plan to pr, show tests in CO
47. Run terraform apply from a CI server, this server should always be in a private subnet without any public ip


"The first rule of functions is that they should be small, the second rule of functions is that they should be smaller than that" Robert C Martin


"It always takes longer than you expect even when you take into account Hofgstatter's law" David Hofdstater

"This is the Unix Philosophy: Write Programs that do one thing and do it well. Write Programs to work together" Doug Mcllroy




For destroying a terraform config that uses a remote backend for state management, you want to first go back to using a local backend by using terraform init, then running destroy so that the 3 bucket can also be deleted




# Master 
- Zero Downtime deployment on aws even with terraform