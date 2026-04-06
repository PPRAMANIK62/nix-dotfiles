{ ... }: {
    home.file.".vimrc".text = ''
        source ~/.vim/vimrc
    '';

    home.file.".vim/vimrc".text = ''
        source ~/.vim/options.vim
        source ~/.vim/keybinds.vim
        source ~/.vim/plugins.vim
        source ~/.vim/colors.vim
        source ~/.vim/fzf.vim
    '';

    home.file.".vim/options.vim".text = ''
        set number
        set relativenumber

        filetype plugin indent on
        set expandtab
        set shiftwidth=4
        set softtabstop=4
        set tabstop=4
        set smartindent

        set backspace=indent,eol,start

        syntax on
    '';

    home.file.".vim/keybinds.vim".text = ''
        let mapleader = " "

        nnoremap <leader>cd :Ex<CR>
    '';

    home.file.".vim/colors.vim".text = ''
        set termguicolors

        set laststatus=2

        let g:tokyonight_style = 'night'
        let g:tokyonight_enable_italic = 1
        let g:lightline = { 'colorscheme' : 'tokyonight' }

        colorscheme tokyonight
    '';

    home.file.".vim/fzf.vim".text = ''
        nnoremap <leader>ff :Files<CR>
        nnoremap <leader>fh :History<CR>
        nnoremap <leader>fb :Buffers<CR>
        nnoremap <leader>fg :Rg<space>
    '';

    home.file.".vim/plugins.vim".text = ''
        let s:plugin_dir = expand('~/.vim/plugged')

        function! s:ensure(repo)
            let name = split(a:repo, '/')[-1]
            let path = s:plugin_dir . '/' . name

            if !isdirectory(path)
                if !isdirectory(s:plugin_dir)
                    call mkdir(s:plugin_dir, 'p')
                endif
                execute '!git clone --depth=1 https://github.com/' . a:repo . ' ' . shellescape(path)
            endif

            execute 'set runtimepath+=' . fnameescape(path)
        endfunction

        call s:ensure('ghifarit53/tokyonight-vim')
        call s:ensure('junegunn/fzf')
        call s:ensure('junegunn/fzf.vim')
        call s:ensure('itchyny/lightline.vim')
        call s:ensure('yegappan/lsp')
    '';
}
