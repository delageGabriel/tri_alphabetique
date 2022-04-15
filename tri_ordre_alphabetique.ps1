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

#############################################################################
#                   ** Création tableaux alphabet **                        #
#############################################################################

$tableauAlphabetMajuscule = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
$tableauAlphabetMinuscule = @('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
$tableauChiffreMajMin     =  @(25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)

#############################################################################
#     ** Création d'une méthode pour extraire des caractères **             #
#############################################################################

function RecupCaractere([string]$mot, [int]$index, [int]$nbCaractereARecup)
{
    $lettre = ""
    $lettre = $mot.Substring($index, $nbCaractereARecup)
    return $lettre
}

#############################################################################
#       ** Création d'une méthode qui va chercher la lettre dans le **      #
#       ** tableau d'alphabet, et l'associer à un chiffre           **      #
#############################################################################