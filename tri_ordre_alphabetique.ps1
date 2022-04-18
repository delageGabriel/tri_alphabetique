#############################################################################
#     ~~ Auteur  : Gabriel DELAGE©                                          #
#     ~~ Version : 1.1.0                                                    #
#############################################################################

#############################################################################
#     ** Récupération du fichier d'où les lignes seront retirées **         #
#############################################################################
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
$objForm = New-Object System.Windows.Forms.OpenFileDialog
$objForm.InitialDirectory = "c:\"
$objForm.Title = "Sélectionner un fichier :"
$objForm.FilterIndex = 3
$Show = $objForm.ShowDialog()
 
if ($Show -eq "Cancel")
{
    "Annulé par l'utilisateur"
}
else
{
    write-host $objForm.FileName
}

#############################################################################
#     ** Stocker le contenu du fichier txt dans une liste **                #
#############################################################################
$list = New-Object 'System.Collections.Generic.List[string]'
$tailleTableau = (Get-Content $objForm.FileName).Length
for($i = 0; $i -lt $tailleTableau ; $i++)
{
   $varTemp = Get-Content -Path $objForm.FileName -Encoding UTF8| where {$_-ne "$null"} | Select-Object -Index $i 
   $list.Add($varTemp)
}

Clear-Content -Path $objForm.FileName

#############################################################################
#                   ** Création tableaux alphabet **                        #
#############################################################################

$tableauAlphabetMajuscule                   = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','')
$tableauAlphabetMinuscule                   = @('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','')
$tableauAlphabetCaracteresSpeciauxMajuscule = @('À','Á','Â','Ã','Ä','Å','Æ','Ç','È','É','Ê','Ë','Ì','Í','Î','Ï','Ð','Ñ','Ò','Ó','Ô','Õ','Ö','Ø','Œ','Š','þ','Ù','Ú','Û','Ü','Ý','Ÿ','')
$tableauAlphabetCaracteresSpeciauxMinuscule = @('à','á','â','ã','ä','å','æ','ç','è','é','ê','ë','ì','í','î','ï','ð','ñ','ò','ó','ô','õ','ö','ø','œ','š','Þ','ù','ú','û','ü','ý','ÿ','')
$tableauChiffreMajMin                       = @(26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)
$tableauChiffreMajMinCaracteresSpeciaux     = @(26,26,26,26,26,26,26,24,22,22,22,22,18,18,18,18,23,13,12,12,12,12,12,12,12,8,1,6,6,6,6,2,2,0)

#############################################################################
#     ** Création d'une méthode pour extraire des caractères **             #
#############################################################################
#     ** $mot -> type: string; mot d'où seront extrait les   **             #
#     ** caractères                                          **             #
#     ** $index -> type: integer; index du mot d'où sera     **             #
#     ** extrait le caractère                                **             #
#     ** $nbCaractereARecup -> type: integer; permet de      **             #
#     ** définir le nombre de caractère à récupérer, bien    **             #
#     ** qu'il ne doit pas dépasser '1'                      **             #
#############################################################################
function Get-Caractere($mot, $index, $nbCaractereARecup)
{
    $lettre = ""
    $lettre = $mot.Substring($index, $nbCaractereARecup)
    return $lettre
}

#############################################################################
#       ** Création d'une méthode qui va chercher la lettre dans le **      #
#       ** tableau d'alphabet, et l'associer à un chiffre           **      #
#############################################################################
#       ** $lettre -> type: char; la lettre sera associée à un      **      #
#       ** nombre, le nombre sera retourné                          **      #
#############################################################################
function Get-ChiffreCaractere($lettre)
{
    for($i = 0 ; $i -lt $tableauAlphabetMajuscule.Count ; $i++)
    {
        if($lettre -eq $tableauAlphabetMajuscule[$i])
        {
            return $tableauChiffreMajMin[$i]
        }        
    }
    for($j = 0; $j -lt $tableauAlphabetMinuscule.Count ; $j++)
    {
        if($lettre -eq $tableauAlphabetMinuscule[$j])
        {
            return $tableauChiffreMajMin[$j]
        }
    }
    for($n = 0; $n -lt $tableauAlphabetCaracteresSpeciauxMajuscule.Count ; $n++)
    {
        if($lettre -eq $tableauAlphabetCaracteresSpeciauxMajuscule[$n])
        {
            return $tableauChiffreMajMinCaracteresSpeciaux[$n]
        }
    }
    for($k = 0; $k -lt $tableauAlphabetCaracteresSpeciauxMinuscule.Count ; $k++)
    {
        if($lettre -eq $tableauAlphabetCaracteresSpeciauxMinuscule[$n])
        {
            return $tableauChiffreMajMinCaracteresSpeciaux[$k]
        }
    }
}

#############################################################################
#     ** Création de variables qui seront utiles lors de             **     #
#     ** l'utilisation de la méthode pour trier alphabétiquement     **     #
#############################################################################
$compteARebours           = $list.Count
$nouvelleListe            = New-Object 'System.Collections.Generic.List[string]'

#############################################################################
#     ** Méthode de tri par ordre alphabétique de A à Z              **     #
#############################################################################
#     ** $cpt -> type: integer; servira pour le compteur             **     #
#     ** $unIndex -> type: integer; utile, si jamais deux caracteres **     #
#     ** dans les mots comparés se ressemblent                       **     #
#     ** $uneListe -> type: arrayList; liste originale d'où sera     **     #
#     ** extrait les mots                                            **     #
#     ** $nouvelleListeMethode -> type: arrayList; nouvelle liste    **     #
#     ** où seront stockés les mots rangés alphabétiquement          **     #
#############################################################################
function Set-TriAlphabetiqueAZ($cpt, $unIndex, $uneListe, $nouvelleListeMethode)
{
    $motLePlusGrand = $null
    $i = 0

    while($i -lt $cpt)
    {
        $k = 0

        for($j = 0 ; $j -lt $uneListe.Count ; $j++)
        {           
            $unIndex = 0

            if($motLePlusGrand -eq $null)
            {
                $motLePlusGrand = $uneListe[$j]
            }
            if($k -eq $j)
            {
                $k = $k + 1
                if($k -gt $uneListe.Count - 1)
                {
                    $k = $uneListe.Count - 1
                } 
            }
            else
            {
                $motAComparer = $uneListe[$k]
            }

            $motAComparer     = $uneListe[$k]
            $lettrePlusGrande = Get-Caractere -mot $motLePlusGrand -index $unIndex -nbCaractereARecup 1
            $chiffrePlusGrand = Get-ChiffreCaractere -lettre $lettrePlusGrande
            $lettreAComparer  = Get-Caractere -mot $motAComparer -index $unIndex -nbCaractereARecup 1
            $chiffreAComparer = Get-ChiffreCaractere -lettre $lettreAComparer

            if($motLePlusGrand -eq $motAComparer)
            {}
            else
            {
                if($chiffrePlusGrand -lt $chiffreAComparer)
                {
                    $motLePlusGrand = $motAComparer
                }
                if($chiffrePlusGrand -eq $chiffreAComparer)
                {
                    while($chiffrePlusGrand -eq $chiffreAComparer)
                    {
                        $unIndex = $unIndex + 1
                        $lettrePlusGrande = Get-Caractere -mot $motLePlusGrand -index $unIndex -nbCaractereARecup 1
                        $chiffrePlusGrand = Get-ChiffreCaractere -lettre $lettrePlusGrande
                        $lettreAComparer  = Get-Caractere -mot $motAComparer -index $unIndex -nbCaractereARecup 1
                        $chiffreAComparer = Get-ChiffreCaractere -lettre $lettreAComparer

                        if($chiffrePlusGrand -lt $chiffreAComparer)
                        {
                            $motLePlusGrand = $motAComparer
                        }
                    }
                }
            }            
         }

         for($x = 0; $x -lt $uneListe.Count; $x++)
         {
            if($motLePlusGrand -eq $uneListe[$x])
            {
                $uneListe.RemoveAt($x)
            }
         }
         
        $nouvelleListeMethode.Add($motLePlusGrand)
        $motLePlusGrand = $null
        $i = $i + 1
        Write-Progress -Activity "Traitement en cours..." -Status "$i complété(s) sur $cpt :" -PercentComplete (($i/$cpt)*100)
        Start-Sleep -Milliseconds 250
    }
}

#############################################################################
#     ** Méthode de tri par ordre alphabétique de Z à A              **     #
#############################################################################
#     ** $cpt -> type: integer; servira pour le compteur             **     #
#     ** $unIndex -> type: integer; utile, si jamais deux caracteres **     #
#     ** dans les mots comparés se ressemblent                       **     #
#     ** $uneListe -> type: arrayList; liste originale d'où sera     **     #
#     ** extrait les mots                                            **     #
#     ** $nouvelleListeMethode -> type: arrayList; nouvelle liste    **     #
#     ** où seront stockés les mots rangés alphabétiquement          **     #
#############################################################################
function Set-TriAlphabetiqueZA($cpt, $unIndex,$uneListe, $nouvelleListeMethode)
{
    $motLePlusPetit = $null
    $i = 0

    while($i -lt $cpt)
    {
        $k = 0

        for($j = 0 ; $j -lt $uneListe.Count ; $j++)
        {           
            $unIndex = 0

            if($motLePlusPetit -eq $null)
            {
                $motLePlusPetit = $uneListe[$j]
            }
            if($k -eq $j)
            {
                $k = $k + 1
                if($k -gt $uneListe.Count - 1)
                {
                    $k = $uneListe.Count - 1
                } 
            }
            else
            {
                $motAComparer = $uneListe[$k]
            }

            $motAComparer     = $uneListe[$k]
            $lettrePlusPetite = Get-Caractere -mot $motLePlusPetit -index $unIndex -nbCaractereARecup 1
            $chiffrePlusPetit = Get-ChiffreCaractere -lettre $lettrePlusPetite
            $lettreAComparer  = Get-Caractere -mot $motAComparer -index $unIndex -nbCaractereARecup 1
            $chiffreAComparer = Get-ChiffreCaractere -lettre $lettreAComparer

            if($motLePlusPetit -eq $motAComparer)
            {}
            else
            {
                if($chiffrePlusPetit -gt $chiffreAComparer)
                {
                    $motLePlusPetit = $motAComparer
                }
                if($chiffrePlusPetit -eq $chiffreAComparer)
                {
                    while($chiffrePlusPetit -eq $chiffreAComparer)
                    {
                        $unIndex = $unIndex + 1
                        $lettrePlusPetite = Get-Caractere -mot $motLePlusPetit -index $unIndex -nbCaractereARecup 1
                        $chiffrePlusPetit = Get-ChiffreCaractere -lettre $lettrePlusPetite
                        $lettreAComparer  = Get-Caractere -mot $motAComparer -index $unIndex -nbCaractereARecup 1
                        $chiffreAComparer = Get-ChiffreCaractere -lettre $lettreAComparer

                        if($chiffrePlusPetit -gt $chiffreAComparer)
                        {
                            $motLePlusPetit = $motAComparer
                        }
                    }
                }
            }            
         }

         for($x = 0; $x -lt $uneListe.Count; $x++)
         {
            if($motLePlusPetit -eq $uneListe[$x])
            {
                $uneListe.RemoveAt($x)
            }
         }
         
        $nouvelleListeMethode.Add($motLePlusPetit)
        $motLePlusPetit = $null
        $i = $i + 1
        Write-Progress -Activity "Traitement en cours..." -Status "$i complété(s) sur $cpt :" -PercentComplete (($i/$cpt)*100)
        Start-Sleep -Milliseconds 250
    }
}

#############################################################################
#     ** On va récupérer la méthode que l'utilisateur veut utiliser, **     #
#     ** pour ensuite s'en servir comme méthode de tri.              **     #
#############################################################################

$ordreDeTri = Read-Host "Tapez 'A' pour que le fichier soit trié de A à Z, tapez 'Z' pour qu'il soit trié de Z à A."

if($ordreDeTri -eq 'A')
{
    Set-TriAlphabetiqueAZ -cpt $compteARebours -unIndex 0 -uneListe $list -nouvelleListeMethode $nouvelleListe
}
elseif($ordreDeTri -eq 'Z')
{
    Set-TriAlphabetiqueZA -cpt $compteARebours -unIndex 0 -uneListe $list -nouvelleListeMethode $nouvelleListe    
}
else
{
    Write-Host "Option non valide, mauvaise saisie."
}

#############################################################################
#     ** Nettoyage complet du fichier txt pour accueillir les        **     #
#     ** nouvelles lignes                                            **     #
#############################################################################
Clear-Content -Path $objForm.FileName

#############################################################################
#     ** Chaque objet de la nouvelle liste sera inséré dans le       **     #
#     ** fichier txt d'origine                                       **     #
#############################################################################
foreach($objets in $nouvelleListe)
{
    Add-Content -Path $objForm.FileName -Value $objets -Encoding UTF8
}

#############################################################################
#     ~~ Date de création : 15 avril 2022                                   #
#     ~~ Dernière date de modification : 18 avril 2022                      #
#############################################################################