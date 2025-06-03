inherit otab_variables_common

do_insert_otab_variables_preinstall() {
  insert_otab_variables
}

addtask do_insert_otab_variables_preinstall after do_unpack before do_configure
