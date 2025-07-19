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