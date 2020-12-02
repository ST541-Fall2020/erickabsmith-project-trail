#' connect to Amazon Elastic Compute Cloud (EC2) to create cluster of R workers
#' 
#' @param public_ip An IP address to ec2 instance
#' @param ssh_private_key_file A filepath to .ppk ssh key
#' @return cluster of R workers connected to EC2 instance
#' @examples
#' connect_to_ec2(public_ip = my_ec2_ip, ssh_private_key_file = path_to_my_ppk_file)

connect_to_ec2 <- function(public_ip, ssh_private_key_file) {
  parallelly::makeClusterPSOCK(
    workers = public_ip,
    user = "ubuntu",
    rshcmd = c("plink", "-ssh", "-i", "C:/Program Files/PuTTY/plink.exe"),
    rshopts = c(
      "-i", ssh_private_key_file
    ),

    dryrun = FALSE,
    verbose = TRUE
  )
}

