new_tbl_invitation <- function(invitations) {
  tibble::new_tibble(invitations, nrow = nrow(invitations), class = "tbl_invitation")
}
