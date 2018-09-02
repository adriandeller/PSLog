function Copy-Object
{
    # Clone an object
    # https://stackoverflow.com/questions/7468707/deep-copy-a-dictionary-hashtable-in-powershell
    param($Object)
    $memStream = New-Object IO.MemoryStream
    $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $formatter.Serialize($memStream, $Object)
    $memStream.Position = 0
    $formatter.Deserialize($memStream)
}
