<?php

/* The file does not exist until some information is entered 
below. Once information is entered and saved, the file will be created. */

$conf['upload_form_all_types'] = true;
$conf['sync_chars_regex'] = '/^[a-zA-Z0-9-_. ]+$/';
$conf['enable_formats'] = true;
$conf['format_ext'] = array('cmyk.jpg', 'cmyk.tif', 'cr2', 'prorgb.jpg', 'jpg', 'jpeg');
$conf['show_exif'] = true;
$conf['show_exif_fields'] = array(
  'Make',
  'Model',
  'ExifVersion',
  'Software',
  'DateTimeOriginal',
  'FNumber',
  'ExposureBiasValue',
  'FILE;FileSize',
  'ExposureTime',
  'Flash',
  'ISOSpeedRatings',
  'FocalLength',
  'FocalLengthIn35mmFilm',
  'WhiteBalance',
  'ExposureMode',
  'MeteringMode',
  'ExposureProgram',
  'LightSource',
  'Contrast',
  'Saturation',
  'Sharpness',
  'bitrate',
  'channel',
  'date_creation',
  'display_aspect_ratio',
  'duration',
  'filesize',
  'format',
  'formatprofile',
  'codecid',
  'frame_rate',
  'latitude',
  'longitude',
  'make',
  'model',
  'playtime_seconds',
  'sampling_rate',
  'type',
  'resolution',
  'rotation',
  );
  
/* end */
?>