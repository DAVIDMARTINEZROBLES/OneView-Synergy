write-host "-----------------------------"
write-host "INVENTARIO DE ENTORNO SYNERGY"
write-host "-----------------------------"
write-host 
if (-not $ConnectedSessions) 
{

	$Appliance = Read-Host 'ApplianceName'
	$Username  = Read-Host 'User'
	$Password  = Read-Host 'Password' -AsSecureString

    $ApplianceConnection = Connect-HPOVMgmt -Hostname $Appliance -Username $Username -Password $Password

}
write-host 
write-host Escribe el nombre deel fichero donde guardar todos los datos
$fichero = Read-Host -Prompt 'Fichero'
$SaltoDeLinea = "################################"

# Muestra configuracion del FRAME

echo $SaltoDeLinea "RACK" $SaltoDeLinea >> $fichero
Get-HPOVRack | Get-HPOVRackMember | fc | Sort-Object Ulocation >> $fichero
echo $SaltoDeLinea "ADDRESS POOL RANGE" $SaltoDeLinea >> $fichero
Get-HPOVAddressPoolRange | fc >> $fichero
echo $SaltoDeLinea "ADDRESS POOL SUBNET" $SaltoDeLinea >> $fichero
Get-HPOVAddressPoolSubnet | fc >> $fichero
echo $SaltoDeLinea "APPLIANCE GLOBAL SETTINGS" $SaltoDeLinea >> $fichero
Get-HPOVApplianceGlobalSetting | fc >> $fichero
echo $SaltoDeLinea "APPLIANCE NETWORK SETTINGS" $SaltoDeLinea >> $fichero
Get-HPOVApplianceNetworkConfig | fc >> $fichero
echo $SaltoDeLinea "APPLIANCE DATE TIME" $SaltoDeLinea >> $fichero
echo "fecha del equipo" >> $fichero
Get-Date -UFormat "%d/%m/%Y  %T" >> $fichero
Get-HPOVApplianceDateTime  >> $fichero
echo "fecha del equipo" >> $fichero
Get-Date -UFormat "%d/%m/%Y  %T" >> $fichero

echo $SaltoDeLinea "COMPOSER" $SaltoDeLinea >> $fichero
Get-HPOVComposerNode | fc >> $fichero
echo $SaltoDeLinea "IMAGE STREAMER" $SaltoDeLinea >> $fichero
Get-HPOVImageStreamerAppliance | fc >> $fichero
echo $SaltoDeLinea "ENCLOSURE" $SaltoDeLinea >> $fichero
Get-HPOVEnclosure | fc >> $fichero
echo $SaltoDeLinea "SERVER RESUME" $SaltoDeLinea >> $fichero
Get-HPOVServer | fc | Sort-Object position >> $fichero
echo $SaltoDeLinea "DRIVE ENCLOSURE RESUME" $SaltoDeLinea >> $fichero
Get-HPOVDriveEnclosure | fc | Sort-Object position >> $fichero
echo $SaltoDeLinea "INTERCONNECT" $SaltoDeLinea >> $fichero
Get-HPOVinterconnect | Fc >> $fichero

Get-HPOVEnclosure | fc >> $fichero

$servers = Get-HPOVserver | Sort-Object locationuri, {[int]$_.position} | fc >> $fichero
$DriveEnclosures = Get-HPOVDriveEnclosure | Sort-Object name, {[int]$_.bay}  | fc >> $fichero

# Muestra configuracion del FRAME

echo $SaltoDeLinea $SaltoDeLinea >> $fichero
echo $SaltoDeLinea "FRAME" $SaltoDeLinea >> $fichero
echo $SaltoDeLinea $SaltoDeLinea >> $fichero

echo $SaltoDeLinea "LOGICAL ENCLOSURE" $SaltoDeLinea >> $fichero
Get-HPOVLogicalEnclosure | fc >> $fichero

echo $SaltoDeLinea "ENCLOSURE GROUP" $SaltoDeLinea >> $fichero
Get-HPOVEnclosureGroup | fc >> $fichero

echo $SaltoDeLinea "LOGICAL INTERCONNECT GROUP" $SaltoDeLinea >> $fichero
Get-HPOVLogicalInterconnectGroup | fc >> $fichero

echo $SaltoDeLinea "UPLINKS" $SaltoDeLinea >> $fichero
Get-HPOVUplinkSet | fc >> $fichero

echo $SaltoDeLinea "NETWORK SET" $SaltoDeLinea >> $fichero
Get-HPOVNetworkSet | fc >> $fichero

echo $SaltoDeLinea "NETWORK" $SaltoDeLinea >> $fichero
Get-HPOVNetwork | fc >> $fichero

echo $SaltoDeLinea "SPP BUNDLES" $SaltoDeLinea >> $fichero
Get-HPOVSppFile | fc >> $fichero

# Muestra configuracion de los Perfiles

echo $SaltoDeLinea $SaltoDeLinea >> $fichero
echo $SaltoDeLinea "PERFILES" $SaltoDeLinea >> $fichero
echo $SaltoDeLinea $SaltoDeLinea >> $fichero

echo $SaltoDeLinea "PROFILE TEMPLATE" $SaltoDeLinea >> $fichero
Get-HPOVServerProfileTemplate | Sort-Object -Property Enclosurebay | fc >> $fichero 

echo $SaltoDeLinea "PROFILES" $SaltoDeLinea >> $fichero
Get-HPOVServerProfile | Sort-Object -Property enclosureBay | fc >> $fichero
