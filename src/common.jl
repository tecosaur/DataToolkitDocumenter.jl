const LICENCE_LINKS = let
    cc = "(?:CC|Creative ?Commons)"
    cc_by = "$cc ?(?:B[Yy]|by|[Aa]ttribution)"
    cc_sa = "(?:S[Aa]|sa|[Ss]hare ?[Aa]like)"
    cc_nd = "(?:N[Dd]|nd|[Nn]o ?[Dd]eriv(?:atives)?)"
    cc_nc = "(?:N[Cc]|nc|[Nn]on[ -]?[Cc]ommercial)"
    cc_4 = "(?:|4|4\\.0)"
    cc_il = "(?: ?[Ii]nternational [Ll]icence)?"
    cc_4il = cc_4 * cc_il
    [Regex("^$cc ?0(?:| 1| 1\\.0)\$") =>
        ("CC0 1.0", "https://creativecommons.org/publicdomain/zero/1.0/"),
     Regex("^$cc_by ?$cc_4il\$") =>
         ("CC BY 4.0", "https://creativecommons.org/licenses/by/4.0/"),
     Regex("^$cc_by[ -]?$cc_sa ?$cc_4il\$") =>
         ("CC BY-SA 4.0", "https://creativecommons.org/licenses/by-sa/4.0/"),
     Regex("^$cc_by[ -]?$cc_nd ?$cc_4il\$") =>
         ("CC BY-ND 4.0", "https://creativecommons.org/licenses/by-nd/4.0/"),
     Regex("^$cc_by[ -]?$cc_nc ?$cc_4il\$") =>
         ("CC BY-NC 4.0", "https://creativecommons.org/licenses/by-nc/4.0/"),
     Regex("^$cc_by[ -]?$cc_nc[ -]?$cc_sa ?$cc_4il\$") =>
         ("CC BY-NC-SA 4.0", "https://creativecommons.org/licenses/by-nc-sa/4.0/"),
     Regex("^$cc_by[ -]?$cc_nc[ -]?$cc_nd ?$cc_4il\$") =>
         ("CC BY-NC-ND 4.0", "https://creativecommons.org/licenses/by-nc-nd/4.0/")]
end
