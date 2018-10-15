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
Get-HPOVRack | Get-HPOVRackMember | Sort-Object Ulocation | ConvertTo-Csv -NoTypeInformation >> $fichero
echo $SaltoDeLinea "ADDRESS POOL RANGE" $SaltoDeLinea >> $fichero
Get-HPOVAddressPoolRange |  ConvertTo-Csv -NoTypeInformation >> $fichero
echo $SaltoDeLinea "ADDRESS POOL SUBNET" $SaltoDeLinea >> $fichero
Get-HPOVAddressPoolSubnet |  ConvertTo-Csv  -NoTypeInformation >> $fichero
echo $SaltoDeLinea "COMPOSER" $SaltoDeLinea >> $fichero
Get-HPOVComposerNode | ft Appliance, modelNumber, name, role, state, status, version, synchronizationPercentComplete | ConvertTo-Csv  -NoTypeInformation >> $fichero
echo $SaltoDeLinea "IMAGE STREAMER" $SaltoDeLinea >> $fichero
Get-HPOVImageStreamerAppliance | ft oneViewIpv4Address, name, status, applianceserialnumber, imagestreamerversion, isactive, isprimary | ConvertTo-Csv >> $fichero
echo $SaltoDeLinea "ENCLOSURE" $SaltoDeLinea >> $fichero
Get-HPOVEnclosure | Sort-Object -Property name | ConvertTo-Csv -NoTypeInformation >> $fichero
echo $SaltoDeLinea "SERVER RESUME" $SaltoDeLinea >> $fichero
Get-HPOVServer | Format-Table position, name, mpModel, mpFirmwareVersion, model, serialNumber, processorType, memoryMb, romVersion, intelligentProvisioningVersion, state, powerState | Sort-Object -Property locationUri, position | ConvertTo-Csv -NoTypeInformation >> $fichero
echo $SaltoDeLinea "DRIVE ENCLOSURE" $SaltoDeLinea >> $fichero
Get-HPOVDriveEnclosure | Format-Table name, bay, model, serialNumber, partNumber, productName, driveBayCount, firmwareVersion, ioAdapterCount, powerState | Sort-Object {[int]$_.bay} | ConvertTo-Csv -NoTypeInformation >> $fichero
echo $SaltoDeLinea "INTERCONNECT" $SaltoDeLinea >> $fichero
Get-HPOVinterconnect | Format-Table enclosureName, hostName,model, name, partNumber, serialNumber, interconnectIP, firmwareVersion, portCount, baseWWN | Sort-Object name | ConvertTo-Csv -NoTypeInformation >> $fichero

$Enclosures = Get-HPOVEnclosure | Sort-Object -Property name
Foreach ($Enclosure in $Enclosures)
{
echo $SaltoDeLinea "ENCLOSURE DETAIL" $Enclosure.name $SaltoDeLinea >> $fichero
echo $SaltoDeLinea "Interconnect" $Enclosure.serialNumber $SaltoDeLinea >> $fichero
  (Send-HPOVRequest -Uri ($Enclosure.uri)).interconnectBays | Format-Table bayNumber, interconnectModel, partNumber, serialNumber, ipv4Setting | Sort-Object -Property bayNumber | ConvertTo-Csv >> $fichero
echo $SaltoDeLinea "Appliance Bays" $Enclosure.serialNumber $SaltoDeLinea >> $fichero
  (Send-HPOVRequest -Uri ($Enclosure.uri)).applianceBays | ft bayNumber, devicePresence, status, model, serialNumber, partNumber, poweredOn | Sort-Object -Property bayNumber | ConvertTo-Csv >> $fichero
echo $SaltoDeLinea "Manager Bays" $Enclosure.serialNumber $SaltoDeLinea >> $fichero
  (Send-HPOVRequest -Uri ($Enclosure.uri)).managerBays | ft bayNumber, model, devicePresence, role, FwVersion, partNumber, sparePartNumber | Sort-Object -Property bayNumber | ConvertTo-Csv >> $fichero
echo $SaltoDeLinea "PowerSupply" $Enclosure.serialNumber $SaltoDeLinea >> $fichero
  (Send-HPOVRequest -Uri ($Enclosure.uri)).powerSupplyBays | Format-Table | Sort-Object -Property bayNumber | ConvertTo-Csv >> $fichero
echo $SaltoDeLinea "Fan" $Enclosure.serialNumber $SaltoDeLinea >> $fichero
  (Send-HPOVRequest -Uri ($Enclosure.uri)).fanBays | Format-Table bayNumber, devicePresence, fanBayType, model, serialNumber, partNumber, sparePartNumber | Sort-Object -Property bayNumber | ConvertTo-Csv >> $fichero
}

$servers = Get-HPOVserver | Sort-Object locationuri, {[int]$_.position} 
Foreach ($server in $servers)
{
echo $SaltoDeLinea "SERVER DETAIL" $server.name $SaltoDeLinea >> $fichero
(Send-HPOVRequest -Uri ($server.uri)).portMap.deviceSlots | Format-Table | ConvertTo-Csv >> $fichero
(Send-HPOVRequest -Uri ($server.uri)).portMap.deviceSlots.physicalPorts | Format-Table type, portNumber, physicalInterconnectPort, interconnectport, mac | ConvertTo-Csv >> $fichero
(Send-HPOVRequest -Uri ($server.uri)).mpHostInfo.mpIpAddresses | Format-Table type, address | ConvertTo-Csv >> $fichero
(Send-HPOVRequest -Uri ($server.uri + "/firmware")).components | Format-Table componentLocation, componentName, componentVersion | Sort-Object componentLocation, componentName | ConvertTo-Csv | Out-File $fichero -Append
}
$DriveEnclosures = Get-HPOVDriveEnclosure | Sort-Object name, {[int]$_.bay} 
Foreach ($DriveEnclosure in $DriveEnclosures)
{
echo $SaltoDeLinea "DRIVE ENCLOSURE DETAIL" $DriveEnclosure.serialNumber $DriveEnclosure.name $SaltoDeLinea >> $fichero
 (Send-HPOVRequest -Uri ($DriveEnclosure.uri)).ioadapters | Format-Table model, partnumber, serialnumber, firmwareversion, portcount, redundantIoModule | ConvertTo-Csv >> $fichero
 (Send-HPOVRequest -Uri ($DriveEnclosure.uri)).driveBays.drive | Format-Table name, serialNumber, model, deviceInterface, driveMedia, linkRateInGbs, drivePaths, firmwareVersion, status, temperature | ConvertTo-Csv >> $fichero
}

# Muestra configuracion del FRAME

echo $SaltoDeLinea $SaltoDeLinea >> $fichero
echo $SaltoDeLinea "FRAME" $SaltoDeLinea >> $fichero
echo $SaltoDeLinea $SaltoDeLinea >> $fichero

echo $SaltoDeLinea "LOGICAL ENCLOSURE" $SaltoDeLinea >> $fichero
Get-HPOVLogicalEnclosure | ConvertTo-Csv >> $fichero

echo $SaltoDeLinea "ENCLOSURE GROUP" $SaltoDeLinea >> $fichero
Get-HPOVEnclosureGroup | ConvertTo-Csv >> $fichero

echo $SaltoDeLinea "LOGICAL INTERCONNECT GROUP" $SaltoDeLinea >> $fichero
Get-HPOVLogicalInterconnectGroup | ConvertTo-Csv >> $fichero

echo $SaltoDeLinea "UPLINKS" $SaltoDeLinea >> $fichero
Get-HPOVUplinkSet | ConvertTo-Csv >> $fichero

echo $SaltoDeLinea "NETWORK SET" $SaltoDeLinea >> $fichero
Get-HPOVNetworkSet | ConvertTo-Csv >> $fichero

echo $SaltoDeLinea "NETWORK" $SaltoDeLinea >> $fichero
Get-HPOVNetwork | ConvertTo-Csv >> $fichero

echo $SaltoDeLinea "SPP BUNDLES" $SaltoDeLinea >> $fichero
Get-HPOVSppFile | ConvertTo-Csv >> $fichero

# Muestra configuracion de los Perfiles

echo $SaltoDeLinea $SaltoDeLinea >> $fichero
echo $SaltoDeLinea "PERFILES" $SaltoDeLinea >> $fichero
echo $SaltoDeLinea $SaltoDeLinea >> $fichero

echo $SaltoDeLinea "PROFILE TEMPLATE" $SaltoDeLinea >> $fichero
Get-HPOVServerProfileTemplate | ConvertTo-Csv >> $fichero

echo $SaltoDeLinea "PROFILES" $SaltoDeLinea >> $fichero
Get-HPOVServerProfile | ConvertTo-Csv >> $fichero
