function Add-ListboxItem
{
param(  [parameter(Mandatory=$true)][System.Windows.Forms.ListBox]$oListbox,
        [parameter(Mandatory=$true)][System.String]$Text)
    $oListbox.Items.Add($Text)
}
function Add-ListviewColumn
{
param(  [parameter(Mandatory=$true)][System.Windows.Forms.ListView]$oListView,
        [parameter(Mandatory=$true)][System.String]$Text,
        [parameter(Mandatory=$false)][Int]$Width,
        [parameter(Mandatory=$false)][Switch]$Hide,
        [parameter(Mandatory=$false)][Alias("Silence","Silent")][Switch]$OutNULL)
    [system.windows.forms.columnheader]$oListViewColumn = $oListView.columns.Add($Text)
    if ($Width)
    {
        $oListView.columns[$($oListViewColumn.Index)].Width = $Width
    }
    if ($Hide)
    {
        $oListView.columns[$($oListViewColumn.Index)].Width = 0
    }
    if ($OutNULL)
    {
        return $null
    }
    else
    {
        return $oListViewColumn
    }
}

function Add-ComboboxItem
{
param(  [parameter(Mandatory=$true,ParameterSetName='Parameter Set 1')]
        [parameter(Mandatory=$true,ParameterSetName='Parameter Set 2')][System.Windows.Forms.ComboBox]$oComboBox,
        [parameter(Mandatory=$true,ParameterSetName='Parameter Set 1')][System.String]$Text,
        [parameter(Mandatory=$true,ParameterSetName='Parameter Set 2')][System.Array]$Array,
        [parameter(Mandatory=$false,ParameterSetName='Parameter Set 1')]
        [parameter(Mandatory=$false,ParameterSetName='Parameter Set 2')][System.Int32]$selIndex = 0)
        if (!([System.string]::IsNullOrEmpty($Text)))
        {
            $oComboBox.Items.Add($Text)
        }
        if (!([System.string]::IsNullOrEmpty($Array)))
        {
            $oComboBox.Items.AddRange($Array)
        }
        if (!([System.string]::IsNullOrEmpty($selIndex)))
        {
            $oComboBox.SelectedIndex = $selIndex
        }
}

function New-FolderBrowserDialog
{
param(  [parameter(Mandatory=$false)][System.String]$SelectedPath,
        [parameter(Mandatory=$false)][Switch]$ShowNewFolderButton,
        [parameter(Mandatory=$false)][System.String]$Description = "Select a directory"        
)
    [System.Windows.Forms.FolderBrowserDialog]$oFolderBrowserForm = New-Object System.Windows.Forms.FolderBrowserDialog
    $oFolderBrowserForm.ShowNewFolderButton = $ShowNewFolderButton
    $oFolderBrowserForm.Description = $Description
    if ($SelectedPath)
    {
        $oFolderBrowserForm.SelectedPath = $SelectedPath
    }

    $oFolderBrowserForm.ShowDialog() | Out-Null
    return $oFolderBrowserForm.SelectedPath
    $oFolderBrowserForm.Dispose() | Out-Null
}

function New-Form
{
param(  [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)][Alias("text")][System.String]$header,
        [parameter(Mandatory=$true)][ValidateSet("Fixed3D", "FixedDialog" ,"FixedSingle", "FixedToolWindow","None","Sizable","SizableToolWindow")][System.String]$borderstyle,
        [parameter(Mandatory=$false)][System.String]$backgroundcolor =  "#ffffff",
        [parameter(Mandatory=$false)][System.String]$icon,
        [parameter(Mandatory=$false)][Switch]$hide_controlbox,
        [parameter(Mandatory=$false)][Switch]$hide_minimizebox,
        [parameter(Mandatory=$false)][Switch]$hide_maximizebox)
    [System.Windows.Forms.Form]$oForm = New-Object System.Windows.Forms.Form
    $oForm.Text = $header
    $oForm.Width = $width
    $oForm.Height = $height
    $oForm.SizeGripStyle = "Hide"
    if ($hide_controlbox)
    {
        $oForm.ControlBox = $false
    }
    if ($hide_minimizebox)
    {
        $oForm.MinimizeBox = $false
    }
    if ($hide_maximizebox)
    {
        $oForm.MaximizeBox = $false
    }
    if (!([String]::IsNullOrEmpty($icon)))
    {
        $oForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($icon)
    }
    if (!([String]::IsNullOrEmpty($backgroundcolor)))
    {
        $oForm.BackColor = $backgroundcolor
    }
    $oForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::$borderstyle
    return $oForm
}

function New-Formbutton
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$true)][ScriptBlock]$Script,
        [parameter(Mandatory=$true)][System.String]$Text,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][System.String]$AltText)
    [System.Windows.Forms.Button]$oButton = New-Object System.Windows.Forms.Button
    $oButton.BackColor = "LightGray"
    $oButton.Add_Click($Script)
    $oButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup                      
    $oButton.Add_Mousemove({$this.Font = New-Object System.Drawing.Font($this.Font.FontFamily,$this.Font.Size,[System.Drawing.FontStyle]::Bold)})
    $oButton.Add_MouseLeave({$this.Font = New-Object System.Drawing.Font($this.Font.FontFamily,$this.Font.Size,[System.Drawing.FontStyle]::Regular)})
    if($Disabled)
    {
        $oButton.Enabled = $false
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oButton,$AltText)
    }
    $oButton.Location = New-Object System.Drawing.Size($x,$y)
    $oButton.Size = New-Object System.Drawing.Size($width,$height)
    $oButton.Text = $Text
    $ParentObject.Controls.Add($oButton)
    return $oButton
}

function New-Formcalendar
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
    [parameter(Mandatory=$true)][System.Int32]$y,
    [parameter(Mandatory=$true)][System.Int32]$width,
    [parameter(Mandatory=$true)][System.Int32]$height,
    [parameter(Mandatory=$true)]$ParentObject,
    [parameter(Mandatory=$false)][System.String]$backgroundcolor,
    [parameter(Mandatory=$false)][DateTime[]]$bolteddates,
    [parameter(Mandatory=$false)][Switch]$Disabled,
    [parameter(Mandatory=$false)][System.Int32]$MaxSelectionCount=1,
    [parameter(Mandatory=$false)][Switch]$ShowTodayCircle
    )
    [System.Windows.Forms.MonthCalendar]$oMonthCalendar = New-Object System.Windows.Forms.MonthCalendar
    $oMonthCalendar.Location = New-Object System.Drawing.Size($x,$y)
    $oMonthCalendar.Size = New-Object System.Drawing.Size($width,$height)
    $oMonthCalendar.date
    if( $backgroundcolor ) {
        $oMonthCalendar.BackColor = $backgroundcolor
    }
    if ($bolteddates) {
        $oMonthCalendar.BoldedDates = $bolteddates
    }
    if ($ShowTodayCircle) {
        $oMonthCalendar.ShowTodayCircle = $true
    }
    $oMonthCalendar.MaxSelectionCount = $MaxSelectionCount
    if ($Disabled) {
        $oMonthCalendar.Enabled = $false
    }
    $ParentObject.Controls.Add($oMonthCalendar)
    return $oMonthCalendar
}

function New-Formcheckbox
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$AltText,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][System.String]$Text,
        [parameter(Mandatory=$false)][System.Drawing.Font]$Font,
        [parameter(Mandatory=$false)][switch]$Checked,
        [parameter(Mandatory=$false)][ScriptBlock]$onChangeScript)
    [System.Windows.Forms.Checkbox]$oCheckbox = New-Object System.Windows.Forms.CheckBox
    $oCheckbox.Location = New-Object System.Drawing.Size($x,$y)
    $oCheckbox.Size = New-Object System.Drawing.Size($width,$height)
    $oCheckbox.Text = $Text
    $ParentObject.Controls.Add($oCheckbox)
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oCheckbox,$AltText)
    }
    if (!([System.string]::IsNullOrEmpty($Font)))
    {
        $oCheckbox.Font = $Font
    }
    if ($Checked)
    {
        $oCheckbox.Checked = $true
    }
    if ($Disabled)
    {
        $oCheckbox.Enabled = $false
    }
    if ($onChangeScript)
    {
        $oCheckbox.Add_Click($onChangeScript)
    }
    return $oCheckbox
}

function New-Formcombobox
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$AltText,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][System.Int32]$DropDownHeight = 300,
        [parameter(Mandatory=$false)][System.String]$backgroundcolor = "#feef94",
        [parameter(Mandatory=$false)][ScriptBlock]$onchange,
        [parameter(Mandatory=$false)][System.String]$Text)
    [System.Windows.Forms.ComboBox]$oNewComboBox = New-Object System.Windows.Forms.ComboBox
    $oNewComboBox.DropDownHeight = $DropDownHeight
    $oNewComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $oNewComboBox.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
    $oNewComboBox.DisplayMember = "NameId"
    $oNewComboBox.Location = New-Object System.Drawing.Size($x,$y)
    $oNewComboBox.Size = New-Object System.Drawing.Size($width,$height)
    $oNewComboBox.Text = $idText
    if (!([String]::IsNullOrEmpty($backgroundcolor)))
    {
        $oNewComboBox.BackColor = $backgroundcolor
    }
    if ($Disabled)
    {
        $oNewComboBox.Enabled = $false
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oNewComboBox,$AltText)
    }
    if ([System.string]::IsNullOrEmpty($Text))
    {
        $oNewComboBox.Text = $Text
    }
    if ($onchange)
    {
        $oNewComboBox.add_SelectedIndexChanged($onchange)
    }
    $ParentObject.Controls.Add($oNewComboBox)    
    return $oNewComboBox
}

function New-FormDataGridView
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.Windows.Forms.DataGridViewAutoSizeColumnsMode]$AutoSizeColumnsMode,
        [parameter(Mandatory=$false)][System.Collections.ArrayList]$alDataSource,
        [parameter(Mandatory=$false)][switch]$AllowUserToAddNewRows,
        [parameter(Mandatory=$false)][switch]$AllowUserToDeleteRows,
        [parameter(Mandatory=$false)][System.String]$BackgroundColorHash,
        [parameter(Mandatory=$false)][System.Array]$Columns,
        [parameter(Mandatory=$false)][switch]$MultiSelect,
        [parameter(Mandatory=$false)][ScriptBlock]$onSelect,
        [parameter(Mandatory=$false)][switch]$ReadOnly,
        [parameter(Mandatory=$false)][ValidateSet("CellSelect", "ColumnHeaderSelect" ,"FullColumnSelect", "FullRowSelect","RowHeaderSelect")][System.String]$SelectionMode = "CellSelect")
    [System.Windows.Forms.DataGridView]$oNewDataGridView = New-Object System.Windows.Forms.DataGridView
    $oNewDataGridView.Location = New-Object System.Drawing.Size($x,$y)
    $oNewDataGridView.Size = New-Object System.Drawing.Size($width,$height)
    if ($alDataSource)
    {
        $oNewDataGridView.DataSource = $alDataSource
    }
    if ($onSelect)
    {
        $oNewDataGridView.Add_CellMouseClick($onSelect)
    }
    if($Columns)
    {
        if ($Columns.Count -ne 0)
        {
            $oNewDataGridView.ColumnHeadersVisible = $true
            $oNewDataGridView.ColumnCount = $Columns.Count
            for($ColumnCounter=0 ; $ColumnCounter -lt $Columns.Count; $ColumnCounter++)
            {
                $oNewDataGridView.Columns[$ColumnCounter].Name = $Columns[$ColumnCounter]
            }
        }
    }
    if ($BackgroundColorHash)
    {
        $oNewDataGridView.BackgroundColor = "#$BackgroundColorHash"
    }
    if ($AllowUserToAddNewRows)
    {
        $oNewDataGridView.AllowUserToAddRows = $true
    }
    else
    {
        $oNewDataGridView.AllowUserToAddRows = $false
    }
    if ($AllowUserToDeleteRows)
    {
        $oNewDataGridView.AllowUserToDeleteRows = $true
    }
    else
    {
        $oNewDataGridView.AllowUserToDeleteRows = $false
    }
    if ($AutoSizeColumnsMode)
    {
        $oNewDataGridView.AutoSizeColumnsMode = $AutoSizeColumnsMode
    }
    if ($ReadOnly)
    {
        $oNewDataGridView.ReadOnly = $true
    }
    else
    {
        $oNewDataGridView.ReadOnly = $false
    }
    if ($MultiSelect)
    {
        $oNewDataGridView.MultiSelect = $true
    }
    else
    {
        $oNewDataGridView.MultiSelect = $false
    }
    if ($SelectionMode)
    {
        $oNewDataGridView.SelectionMode = $SelectionMode
    }
    $ParentObject.Controls.Add($oNewDataGridView)
    return $oNewDataGridView
}

function New-Formdatetimepicker {
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][DateTime]$MinDate,
        [parameter(Mandatory=$false)][DateTime]$MaxDate,
        [parameter(Mandatory=$false)][DateTime]$SelectDate,
        [parameter(Mandatory=$false)][String]$AltText
    )
    [System.Windows.Forms.DateTimePicker]$oNewDateTimePicker = New-Object System.Windows.Forms.DateTimePicker
    $oNewDateTimePicker.Location = New-Object System.Drawing.Size($x,$y)
    $oNewDateTimePicker.Size = New-Object System.Drawing.Size($width,$height)
    $ParentObject.Controls.Add($oNewDateTimePicker)
    if ($Disabled)
    {
        $oNewDateTimePicker.Enabled = $False
    }
    if ($MinDate){
        $oNewDateTimePicker.MinDate = $MinDate
    }
    if ($MaxDate){
        $oNewDateTimePicker.MaxDate = $MaxDate
    }
    if ($SelectDate){
        $oNewDateTimePicker.Value = $SelectDate 
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oNewDateTimePicker,$AltText)
    }
    return $oNewDateTimePicker
}

function New-Formlabel
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$Text,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][Switch]$Readonly,
        [parameter(Mandatory=$false)][System.String]$BackColor,
        [parameter(Mandatory=$false)][System.String]$ForeColor,
        [parameter(Mandatory=$false)][ValidateSet('BottomCenter','BottomLeft','BottomRight','MiddleCenter','MiddleLeft','MiddleRight','TopCenter','TopLeft','TopRight')][System.String]$TextAlign,
        [parameter(Mandatory=$false)][System.Drawing.Font]$Font,
        [parameter(Mandatory=$false)][Switch]$Bold,
        [parameter(Mandatory=$false)][System.String]$AltText)
    [System.Windows.Forms.Label]$oNewLabel = New-Object System.Windows.Forms.Label
    $oNewLabel.Location = New-Object System.Drawing.Size($x,$y)
    $oNewLabel.Size = New-Object System.Drawing.Size($width,$height)
    $ParentObject.Controls.Add($oNewLabel)
    if (!([System.string]::IsNullOrEmpty($BackColor)))
    {
        $oNewLabel.BackColor = $BackColor
    }
    if (!([System.string]::IsNullOrEmpty($ForeColor)))
    {
        $oNewLabel.ForeColor = $ForeColor
    }
    if (!([System.string]::IsNullOrEmpty($Font)))
    {
        $oNewLabel.Font = $Font
    }
    if ($Bold)
    {
        $oNewLabel.Font = New-Object System.Drawing.Font($oNewLabel.Font.FontFamily,$oNewLabel.Font.Size,[System.Drawing.FontStyle]::Bold)
    }
    if (!([System.string]::IsNullOrEmpty($TextAlign)))
    {
        $oNewLabel.TextAlign = $TextAlign
    }
    if (!([System.string]::IsNullOrEmpty($Text)))
    {
        $oNewLabel.Text = $Text
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oNewLabel,$AltText)
    }
    if ($Disabled)
    {
        $oNewLabel.Enabled = $False
    }
    if ($Readonly)
    {
        $oNewLabel.ReadOnly  = $True
    }
    return $oNewLabel
}

function New-Formlistbox
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String][ValidateSet("MultiSimple", "MultiExtended" ,"None")]$SelectionMode,
        [parameter(Mandatory=$false)][System.String]$AltText,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][System.String]$backgroundcolor,
        [parameter(Mandatory=$false)][System.String]$Text)
    [System.Windows.Forms.ListBox]$oNewListBox = New-Object System.Windows.Forms.ListBox
    $oNewListBox.Location = New-Object System.Drawing.Size($x,$y)
    $oNewListBox.Size = New-Object System.Drawing.Size($width,$height)
    if ($SelectionMode)
    {
        $oNewListBox.SelectionMode = $SelectionMode
    }
    $oNewListBox.DisplayMember = "NameId"
    if (!([String]::IsNullOrEmpty($backgroundcolor)))
    {
        $oNewListBox.BackColor = $backgroundcolor
    }
    if ($Disabled)
    {
        $oNewListBox.Enabled = $false
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oNewListBox,$AltText)
    }
    if ([System.string]::IsNullOrEmpty($Text))
    {
        $oNewListBox.Text = $Text
    }
    $ParentObject.Controls.Add($oNewListBox)
    return $oNewListBox
}

function New-Formlistview
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$AltText,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][System.String]$backgroundcolor,
        [parameter(Mandatory=$false)][ScriptBlock]$onclickscript,
        [parameter(Mandatory=$false)][Switch]$Scrollable,
        [parameter(Mandatory=$false)][System.String]$Text,
        [parameter(Mandatory=$false)][System.String][ValidateSet("Details", "LargeIcon" ,"List","SmallIcon","Tile")]$View )

    [System.Windows.Forms.ListView]$oNewListView = New-Object System.Windows.Forms.ListView
    $oNewListView.Location = New-Object System.Drawing.Size($x,$y)
    $oNewListView.Size = New-Object System.Drawing.Size($width,$height)
    if (!([String]::IsNullOrEmpty($backgroundcolor)))
    {
        $oNewListView.BackColor = $backgroundcolor
    }
    if ($Disabled)
    {
        $oNewListView.Enabled = $false
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oNewListView,$AltText)
    }
    if ([System.string]::IsNullOrEmpty($Text))
    {
        $oNewListView.Text = $Text
    }
    if ($onclickscript)
    {
        $oNewListView.FullRowSelect = $true
        $oNewListView.Add_MouseClick($onclickscript)
    }
    if ($Scrollable)
    {
        $oNewListView.Scrollable = $true
    }
    if ($View)
    {
        $oNewListView.View = $View
    }
    $ParentObject.Controls.Add($oNewListView)
    return $oNewListView
}

function New-Formpanel
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$backgroundcolor)
    [System.Windows.Forms.Panel]$oPanel  = New-Object System.Windows.Forms.Panel
    $oPanel.Location = New-Object System.Drawing.Size($x,$y)
    $oPanel.Size = New-Object System.Drawing.Size($width,$height)
    if (!([String]::IsNullOrEmpty($backgroundcolor)))
    {
        $oPanel.BackColor = $backgroundcolor
    }
    $ParentObject.Controls.Add($oPanel)
    return $oPanel
}

function New-Formpicture
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][ScriptBlock]$script,
        [parameter(Mandatory=$false)][System.String]$PictureFile,
        [parameter(Mandatory=$false)][System.String]$AltText)

    $pbNew = new-object Windows.Forms.PictureBox
    $pbNew.Location = New-Object System.Drawing.Size($x,$y)
    if (($width -eq 0) -or ($height -eq 0))
    {
        $pbNew.Width =  $PicLogo.Size.Width
        $pbNew.Height =  $PicLogo.Size.Height
    }
    else
    {
        $pbNew.Width =  $width
        $pbNew.Height =  $height
    }
    $pbNew.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $pbNew.Image = [System.Drawing.Image]::Fromfile($PictureFile)
    $pbNew.Text = $AltText
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($pbNew,$AltText)
    }
    $pbNew.Add_Click($script)
    $ParentObject.Controls.Add($pbNew)
    return @(,$pbNew)
}

function New-Formradiobutton
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$AltText,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][System.String]$Text,
        [parameter(Mandatory=$false)][System.Drawing.Font]$Font,
        [parameter(Mandatory=$false)][Switch]$Checked)
    [System.Windows.Forms.RadioButton]$oRadioButton = New-Object System.Windows.Forms.RadioButton
    $oRadioButton.Location = New-Object System.Drawing.Size($x,$y)
    $oRadioButton.Size = New-Object System.Drawing.Size($width,$height)
    $oRadioButton.Text = $Text
    $ParentObject.Controls.Add($oRadioButton)
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oRadioButton,$AltText)
    }
    if (!([System.string]::IsNullOrEmpty($Font)))
    {
        $oRadioButton.Font = $Font
    }
    if ($Checked)
    {
        $oRadioButton.Checked = $true
    }
    if ($Disabled)
    {
        $oRadioButton.Enabled = $false
    }
    return $oRadioButton
}

function New-Formrichtextbox
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$AltText,
        [parameter(Mandatory=$false)][System.String]$BackColor,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][Switch]$Multiline,
        [parameter(Mandatory=$false)][Switch]$Readonly,
        [parameter(Mandatory=$false)][ScriptBlock]$EnterPressScript,
        [parameter(Mandatory=$false)][System.Windows.Forms.RichTextBoxScrollBars]$ScrollBars,
        [parameter(Mandatory=$false)][System.String]$Text)
    [System.Windows.Forms.RichTextBox]$oNewRichTextBox = New-Object System.Windows.Forms.RichTextBox
    Set-Variable oNewRichTextBox -Value $oNewRichTextBox -Scope Script
    $oNewRichTextBox.Location = New-Object System.Drawing.Size($x,$y)
    $oNewRichTextBox.Size = New-Object System.Drawing.Size($width,$height)
    $ParentObject.Controls.Add($oNewRichTextBox)
    if (!([System.string]::IsNullOrEmpty($BackColor)))
    {
        $oNewRichTextBox.BackColor = $BackColor
    }
    if (!([System.string]::IsNullOrEmpty($Text)))
    {
        $oNewRichTextBox.Text = $Text
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oNewRichTextBox,$AltText)
    }
    if ($Disabled)
    {
        $oNewRichTextBox.Enabled = $False
    }
    if ($Multiline)
    {
        $oNewRichTextBox.Multiline = $Multiline
    }
    if ($EnterPressScript)
    {
        Set-Variable EnterPressScript -Value $EnterPressScript -Scope Script
        $oNewTextBox.Add_KeyPress({
            If($_.KeyChar -eq [System.Windows.Forms.Keys]::Enter)
            {
                Invoke-Command $EnterPressScript
            }
        })
    }
    if ($ScrollBars)
    {
        $oNewRichTextBox.ScrollBars = $ScrollBars
    }
    if ($Readonly)
    {
        $oNewRichTextBox.ReadOnly  = $Readonly
    }
    return $oNewRichTextBox
}

function New-Formtabcontrol
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)]$name,
        [parameter(Mandatory=$false)][System.String][ValidateSet("Buttons", "FlatButtons")]$appearance = "Buttons")
    [System.Windows.Forms.TabControl]$oNewTabControl = New-Object System.Windows.Forms.TabControl
    if ($name)
    {
        $oNewTabControl.Name = $name
    }
    $oNewTabControl.Location = New-Object System.Drawing.Size($x,$y)
    $oNewTabControl.Size = New-Object System.Drawing.Size($width,$height)
    $oNewTabControl.Appearance = $appearance
    $ParentObject.Controls.Add($oNewTabControl)
    return $oNewTabControl
}

function New-Formtabpage
{
param(  [parameter(Mandatory=$false)][System.Int32]$x,
        [parameter(Mandatory=$false)][System.Int32]$y,
        [parameter(Mandatory=$false)][System.Int32]$width,
        [parameter(Mandatory=$false)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$text,
        [parameter(Mandatory=$false)][System.String]$backgroundcolor)
    [System.Windows.Forms.TabPage]$oNewTabPage  = New-Object System.Windows.Forms.TabPage
    $oNewTabPage.Location = New-Object System.Drawing.Size($x,$y)
    $oNewTabPage.Size = New-Object System.Drawing.Size($width,$height)
    if (!([String]::IsNullOrEmpty($backgroundcolor)))
    {
        $oNewTabPage.BackColor = $backgroundcolor
    }
    if (!([String]::IsNullOrEmpty($text)))
    {
        $oNewTabPage.text = $text
    }
    $ParentObject.Controls.Add($oNewTabPage)
    return $oNewTabPage
}

function New-Formtextbox
{
param(  [parameter(Mandatory=$true)][System.Int32]$x,
        [parameter(Mandatory=$true)][System.Int32]$y,
        [parameter(Mandatory=$true)][System.Int32]$width,
        [parameter(Mandatory=$true)][System.Int32]$height,
        [parameter(Mandatory=$true)]$ParentObject,
        [parameter(Mandatory=$false)][System.String]$Text,
        [parameter(Mandatory=$false)][Switch]$Disabled,
        [parameter(Mandatory=$false)][Switch]$Readonly,
        [parameter(Mandatory=$false)][ScriptBlock]$EnterPressScript,
        [parameter(Mandatory=$false)][System.String]$BackColor,
        [parameter(Mandatory=$false)][System.String]$AltText)
    [System.Windows.Forms.TextBox]$oNewTextBox = New-Object System.Windows.Forms.TextBox
    $oNewTextBox.Location = New-Object System.Drawing.Size($x,$y)
    $oNewTextBox.Size = New-Object System.Drawing.Size($width,$height)
    $ParentObject.Controls.Add($oNewTextBox)
    if (!([System.string]::IsNullOrEmpty($BackColor)))
    {
        $oNewTextBox.BackColor = $BackColor
    }
    if (!([System.string]::IsNullOrEmpty($Text)))
    {
        $oNewTextBox.Text = $Text
    }
    if (!([System.string]::IsNullOrEmpty($AltText)))
    {
        [System.Windows.Forms.ToolTip] $Tooltip = New-Object System.Windows.Forms.ToolTip
        $Tooltip.setToolTip($oNewTextBox,$AltText)
    }
    if ($EnterPressScript)
    {
        Set-Variable EnterPressScript -Value $EnterPressScript -Scope Script
        $oNewTextBox.Add_KeyPress({
            If($_.KeyChar -eq [System.Windows.Forms.Keys]::Enter)
            {
                Invoke-Command $EnterPressScript
            }
        })
    }
    if ($Disabled)
    {
        $oNewTextBox.Enabled = $False
    }
    if ($Readonly)
    {
        $oNewTextBox.ReadOnly  = $True
    }
    return $oNewTextBox
}

function New-Formtoolstripmenuitem
{
param(  [parameter(Mandatory=$true)][System.String]$width,
        [parameter(Mandatory=$true)][System.String]$height,
        [parameter(Mandatory=$true)][System.String]$Text,
        [parameter(Mandatory=$true)][Alias("ParentObject")]$MenuObject,
        [parameter(Mandatory=$false)][System.String]$BackColor,
        [parameter(Mandatory=$false)][ScriptBlock]$Script)

    [System.Windows.Forms.ToolStripMenuItem]$oNewToolStripMenuItemNew = New-Object System.Windows.Forms.ToolStripMenuItem
    $oNewToolStripMenuItemNew.Size = New-Object System.Drawing.Size($width,$height)
    $oNewToolStripMenuItemNew.Text = $Text
    if (!([System.string]::IsNullOrEmpty($BackColor)))
    {
        $oNewToolStripMenuItemNew.BackColor = $BackColor
    }
    if ($MenuObject.GetType().fullname -eq "System.Windows.Forms.ToolStripMenuItem" )
    {
        $MenuObject.DropDownItems.Add($oNewToolStripMenuItemNew)
    }
    else
    {
        $MenuObject.Items.Add($oNewToolStripMenuItemNew)
    }
    if (!([System.string]::IsNullOrEmpty($Script)))
    {
        $oNewToolStripMenuItemNew.Add_Click($Script)
    }
    return $oNewToolStripMenuItemNew
}

Function Write-Richrextbox {
Param(
    [Parameter(mandatory=$true)][System.String]$Text,
    [Parameter(mandatory=$true)][System.Windows.Forms.RichTextBox]$RichTextBoxToWriteOn,
    [parameter(Mandatory=$false)][Switch]$NoNewLine,
    [parameter(Mandatory=$false)][Switch]$NoAutoScroll,
    [Parameter(mandatory=$false)][System.Drawing.Color]$ForegroundColor
)  
    [Int]$iStarttext = $RichTextBoxToWriteOn.TextLength
    if ($NoNewLine)
    {
        $RichTextBoxToWriteOn.AppendText($Text)
    }
    else
    {
        $RichTextBoxToWriteOn.AppendText("$Text`r`n")
    }
    [Int]$iStoptest = $RichTextBoxToWriteOn.TextLength
    $RichTextBoxToWriteOn.SelectionStart = $iStarttext
    $RichTextBoxToWriteOn.SelectionLength = $iStoptest - $iStarttext
    if ($ForegroundColor)
    {
        $RichTextBoxToWriteOn.SelectionColor = $ForegroundColor
    }
    if (-not($NoAutoScroll))
    {
        $RichTextBoxToWriteOn.ScrollToCaret()
    }
}

