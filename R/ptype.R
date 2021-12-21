NA_datetime_ <- vctrs::new_datetime(NA_real_, tzone = "UTC")

rscloud_ptypes_30 <- list(
  usages = tibble::tibble(
    "user_id" = NA_integer_,
    "display_name" = NA_character_,
    "first_name" = NA_character_,
    "last_name" = NA_character_,
    "last_activity" = NA_datetime_,
    "compute" = NA_integer_,
    "active_accounts" = NA_integer_,
    "active_spaces" = NA_integer_,
    "active_users" = NA_integer_,
    "active_projects" = NA_integer_,
    "deleted" = NA,
    "deleted_time" = NA,
    "from" = NA_datetime_,
    "until" = NA_datetime_,
  )
)

rscloud_ptypes_90 <- list(
  usages = tibble::tibble(
    "user_id" = NA_integer_,
    "display_name" = NA_character_,
    "first_name" = NA_character_,
    "last_name" = NA_character_,
    "compute" = NA_real_,
    "active_accounts" = NA_integer_,
    "active_spaces" = NA_integer_,
    "active_users" = NA_integer_,
    "active_projects" = NA_integer_,
    "deleted" = NA,
    "deleted_time" = NA,
    "from" = NA_datetime_,
    "until" = NA_datetime_,
  )
)
