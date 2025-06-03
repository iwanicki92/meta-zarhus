inherit otab_variables_common

do_insert_otab_variables_postinstall() {
  insert_otab_variables
}

addtask do_insert_otab_variables_postinstall after do_install before do_package
