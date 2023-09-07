# Define the list of users to exclude from removal
$excludedUsers = @("Administrator","MIPCSAdmin")

# Get the members of the Administrators group using the [ADSI] accelerator
$administratorsGroup = [ADSI]"WinNT://./Administrators,group"

# Get all members of the Administrators group
$members = $administratorsGroup.Invoke("Members") | ForEach-Object {
    $user = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    $sid = $_.GetType().InvokeMember("ObjectSid", 'GetProperty', $null, $_, $null)
    [PSCustomObject]@{
        UserName = $user
        SID = $sid
    }
}

# Remove each member from the Administrators group, excluding the specified users
foreach ($member in $members) {
    # Check if the member should be excluded from removal
    if ($excludedUsers -contains $member.UserName) {
        Write-Host "User $($member.UserName) is excluded from removal."
        continue
    }
    Remove-LocalGroupMember -Group "Administrators" -Member $member.UserName

    # Remove the member from the Administrators group
    #$administratorsGroup.Invoke("Remove", [System.Type]::GetType("System.DirectoryServices.DirectoryEntry"), $member.SID)
    #Write-Host "User $($member.UserName) with SID $($member.SID) has been removed from the Administrators group."


	#Write-Host "All members, except the specified exclusions, have been removed from the Administrators group."
}
shutdown /l /f
