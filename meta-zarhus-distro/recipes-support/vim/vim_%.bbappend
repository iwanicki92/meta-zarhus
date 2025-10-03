FIX_HOME_END_KEYS = "1"
# don't create "<file>~" files
NO_BACKUP_FILE = "1"
# don't create ".<file>.un~" files
NO_UNDO_FILE = "1"

do_install:append() {
    defaults_file="${D}${datadir}/vim/vim91/defaults.vim"
    if [ "${FIX_HOME_END_KEYS}" = "1" ]; then
        # Make sure HOME/END keys work
        echo "map <esc>OH <home>" >> "${defaults_file}"
        echo "cmap <esc>OH <home>" >> "${defaults_file}"
        echo "imap <esc>OH <home>" >> "${defaults_file}"
        echo "map <esc>OF <end>" >> "${defaults_file}"
        echo "cmap <esc>OF <end>" >> "${defaults_file}"
        echo "imap <esc>OF <end>" >> "${defaults_file}"
    fi

    if [ "${NO_BACKUP_FILE}" = "1" ]; then
        echo "set nobackup" >> "${defaults_file}"
    fi

    if [ "${NO_UNDO_FILE}" = "1" ]; then
        echo "set noundofile" >> "${defaults_file}"
    fi
}
