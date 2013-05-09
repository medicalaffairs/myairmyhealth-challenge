
<?php 
$xml_data ='<respiratory>'.
				'<devId>111-111111111111</devId>'.
				'<timeOffset>-14400</timeOffset>'.
				'<measurements>'.
					'<groupid>1</groupid>'.
					'<measure>'.
						'<id>'.(rand()/100000).'</id>'.
						'<time>'.rand().'</time>'.
						'<fev1>4.0</fev1>'.
						'<fev6>4.1</fev6>'.
						'<pef>600</pef>'.
						'<fvc>4.7</fvc>'.
					'</measure>'.
					'<measure>'.
						'<id>'.(rand()/100000).'</id>'.
						'<time>'.rand().'</time>'.
						'<fev1>4.2</fev1>'.
						'<fev6>4.7</fev6>'.
						'<pef>620</pef>'.
						'<fvc>4.9</fvc>'.
					'</measure>'.
				'</measurements>'.
			'</respiratory>';

 
 
$URL = "https://myairmyhealth.medicalaffairs.philips.com/respflowdata/d279420287";
#$URL = "http://localhost:3000/respflowdata/944ba6feda";

			$ch = curl_init($URL);
			curl_setopt($ch, CURLOPT_MUTE, 1);
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
			curl_setopt($ch, CURLOPT_POST, 1);
			curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: text/xml'));
			curl_setopt($ch, CURLOPT_POSTFIELDS, "$xml_data");
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			$output = curl_exec($ch);
			curl_close($ch);
 echo $output."\n";
?>
