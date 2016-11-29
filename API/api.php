<?php
date_default_timezone_set('Europe/Amsterdam');
$target_dir = "uploads/";
$target_file = $target_dir .  date('d_m_Y_H_i_s') . '_'. $_FILES["fileToUpload"]["name"];
$uploadOk = 1;
$imageFileType = pathinfo($target_file,PATHINFO_EXTENSION);

// Check if file already exists
if (file_exists($target_file)) {
    echo "Sorry, file already exists.";
    $uploadOk = 0;
}

// Allow certain file formats
if($imageFileType != "apk" ) {
    echo "Sorry, only apk's are allowed.";
    $uploadOk = 0;
}
// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    echo "\nYour file was not uploaded.";
// if everything is ok, try to upload file
} else {
    if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        echo "The file ". basename( $_FILES["fileToUpload"]["name"]). " has been uploaded.";
    } else {
        echo "Sorry, there was an error uploading your file.";
    }
}
//shell_exec(sh scripts/mdInstaller.sh $target_file)

	$output = shell_exec('sh scripts/mdInstaller.sh ' . $target_file);
    echo "<pre>$output</pre>";


?>