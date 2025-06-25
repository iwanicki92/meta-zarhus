inherit otab_variables_common

fakeroot do_insert_otab_variables_postinstall() {
  insert_otab_variables
}

do_insert_otab_variables_postinstall[depends] += "virtual/fakeroot-native:do_populate_sysroot"

addtask do_insert_otab_variables_postinstall after do_install before do_package
