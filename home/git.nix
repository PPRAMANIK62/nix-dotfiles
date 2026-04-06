{ ... }: {
    programs.git = {
        enable    = true;
        userName  = "Purbayan Pramanik";
        userEmail = "purbayanpramanik62@gmail.com";
        signing = {
            key           = "C5C35170013BB4E5";
            signByDefault = true;
        };
        extraConfig = {
            commit.gpgsign = true;
            tag.gpgsign    = true;
        };
    };
}
