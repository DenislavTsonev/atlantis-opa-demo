package users_allowed_to_apply

users_allowed_to_apply := {
    "prod" : ["Dido"],
    "dev": ["Dido"],
    "uat": ["Dido"],
}

# Replace Bitbucket User account ID with actuall account ID, something like 613b10193249560571b00c00

users_pretty_names := {
  "Bitbucket User account ID" : "Denislav",
  "Bitbucket User account ID" : "Dido"
}


runtime := opa.runtime()
user := runtime.env.USER_NAME
environment := runtime.env.ENVIRONMENT

contains(user, elem) {
  user[_] = elem
}

deny[msg] {
  allowed_users := users_allowed_to_apply[environment]
  user_pretty_name := users_pretty_names[user]
  not contains(allowed_users, user_pretty_name)
  
  msg := sprintf(
        "Your user %q is not authorized to apply into environment  %q.",
        [user_pretty_name, environment]
  )
}
