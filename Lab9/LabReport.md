# Terraform Loop Constructs and Functions Demo

## How to Run

- Clone the repository
- Move to Lab8 folder ( cd Lab8 )
- Run `terraform init`
- Run `terraform apply
- When asked for project name give an appropriate name as input
- Access the load balancer URL to see rotating instance responses


### for_each Implementation
- Creates 3 EC2 instances using for_each
- Each instance shows unique number in web page

#### String Functions
- `lower()` - converts project name to lowercase for consistent naming

#### Date/Time Functions  
- `formatdate()` - adds current date to resource names (MM-DD format)
- `timestamp()` - gets current time for tagging

### Numeric Functions
- `min()` - ensures we don't exceed available AZs
- `max()` - guarantees at least 1 AZ is used
- `%` (modulo) - distributes instances across subnets evenly

### Collection Functions
- `length()` - counts available AZs and subnets
- `values()` - extracts subnet IDs into list

### IP Networking Functions
- `cidrsubnet()` - automatically calculates subnet CIDR blocks from VPC CIDR

## Key Benefits

- I have seen availability zones count differing based on regions. The new tf files is reliable since it takes care of count of AZ available for use.
- I have had a bad feeling about cidr hardcoded values. Now the subnets are automatically assigned at runtime so its more flexible.
- Tags now uses project name so that its easy to identify resources that were created for the project. It becomes easy for identification and manual cleanup if needed.
- Adding instances becomes easy.
- Can be used to deploy multiple projects

# Key Benefits : **cidrsubnet** function usage :

- Instead of hardcoding the subnet for each instance and manually changing it to confirm that it doesnt overlap was a bit problamatic and required manual intervention whenever we wanted to add a new instance. Adding instance should be seamless and easy and we should be getting rid of manual intervention and manual code changes required to get it up and running after an instance addition. This will help in quick scaling, handling unexpected peak traffic etc. 

So moving away from hardcoding the subnet ip ranges and relying on cidrsubnet function helps us in achieving this. Now our code is robust and we can change the number of instances with no code changes required. Instead the input would decide how many and we can keep a default also and the subnets will be assigned automatically without overlaps and conflicts which will help us in scaling easily.