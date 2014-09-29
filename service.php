<?php
$configFolder = "configurations";
switch ($_GET["mode"]) {
	case "get":
		$configurations = Array();
		if ($handle = opendir($configFolder)) {

			while (false !== ($file = readdir($handle))) {
				if ($file != "." && $file != "..") {
					$filePath = $configFolder . "/" . $file;
					$filePointer = fopen($filePath, "r");
					$contents = "";
					while ($content = fgets($filePointer, filesize($filePath))) {
						$contents .= $content;
					}
					fclose($filePointer);
					array_push($configurations, $contents);


				}
			}
			closedir($handle);

		}
		echo json_encode($configurations);
		break;
	case "delete":
		$id = $_POST["data"];
		$filePath = $configFolder . "/" . $id;
		unlink($filePath);

		break;
	case "save":
		$file = $_POST["uuid"];
		$content = json_encode($_POST);
		$filePath = $configFolder . "/" . $file;
		$fp = fopen($filePath, "w");
		fwrite($fp, $content);
		fclose($fp);

		break;
	default:
		header("HTTP/1.0 500 Internal Server Error");
		break;
}