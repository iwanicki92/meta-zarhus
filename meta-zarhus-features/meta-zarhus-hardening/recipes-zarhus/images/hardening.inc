DEPENDS:append = " openssl-native"
inherit extrausers
EXTRA_USERS_PARAMS:append = " useradd -p '' -mG sudo user;  passwd-expire user;"
