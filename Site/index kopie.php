<h1 style="font-family: Helvetica, Arial; font-size: 14">Upload your application</h1>
<form action="" method="post" enctype="multipart/form-data">
    <input type="file" name="file" id="file" />
    <input type="submit" name="submit" value="submit"/>
</form>
<div style=" background-color: #58626F; height: 4px;"  ></div>
<?php
error_reporting(0);
if(isset($_POST['submit']))
{
    $temp_name = $_FILES["file"]["tmp_name"]; // get the temporary filename/path on the server
    $nameOG = $_FILES["file"]["name"]; // get the filename of the actual file
    $name = date("Y-m-d-h:i:s") . "-" . $nameOG;
  
    // print the array (for reference)
    //print_r($_FILES);
          
    // Create uploads folder if it doesn't exist.
    if (!file_exists("uploads")) {
        mkdir("uploads", 0755);
        chmod("uploads", 0755); // Set read and write permissions of folder, needed on some servers
    }
          
    // Move file from temp to uploads folder
    move_uploaded_file($temp_name, "uploads/$name");
    chmod("uploads/$name", 0644); // Set read and write permissions if file

    // Execute install script.
    $output = shell_exec('sh mdInstaller\ Beta.sh uploads/' . $name);
    echo "<pre>$output</pre>";
    echo "$name\n";
    
  

}
?> 