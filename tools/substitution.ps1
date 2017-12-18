<#
	.SYNOPSIS
	Simple text substitution tool.

	.DESCRIPTION
	Reads a text file and performs a series of text substitutions to create a new file.

	.PARAMETER InputFile
	The file containing placeholders to be processed.  Required.

	.PARAMETER OutputFile
	The name of the file to write the processed output to.  Required.

	.PARAMETER SubstituteList
	An XML data file containining a list of substitutions to be performed.  Substitutions follow the form

	<substitutions>
		<substitute>
			<find>SIMPLE_TEXT</find>
			<replacement>This is some text</replacement>
		</substitute>
		<substitute>
			<find>HTML_TEXT</find>
			<replacement><![CDATA[This is a longer bit of text,  it contains<br> some HTML.
			]]></replacement>
		</substitute>
	</substitutions>


#>

Param(
	[Parameter(mandatory=$true, ValueFromPipeline=$false)]
	[string]$InputFile,

	[Parameter(mandatory=$true, ValueFromPipeline=$false)]
	[string]$OutputFile,

	[Parameter(mandatory=$true, ValueFromPipeline=$false)]
	[string]$SubstituteList
)

[xml]$substitutions = Get-Content $SubstituteList
[string]$data = Get-Content -Raw $InputFile

foreach($substitute in $substitutions.substitutions.substitute) {

	$find = "{$($substitute.find)}"
	$replacement = $substitute.replacement
	if($replacement.GetType() -eq [System.Xml.XmlElement] ) {
		if($replacement.FirstChild -ne $null -and $replacement.FirstChild.GetType() -eq [System.Xml.XmlCDataSection]) {
			$replacement = $replacement.FirstChild.Value
		} else {
			Write-Error "Unknown replacement node type."
			exit
		}
	}

	$data = $data.Replace($find, $replacement)
}

Set-Content -Path $OutputFile -Value $data
