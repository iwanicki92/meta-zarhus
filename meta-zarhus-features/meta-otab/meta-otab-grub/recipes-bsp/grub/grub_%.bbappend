require otab-grub-common.inc
inherit deploy

do_deploy() {
}

addtask deploy after do_install before do_build
