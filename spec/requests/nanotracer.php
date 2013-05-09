
<?php 
$xml_data ='<nanoreporter>'.
				'<devId>SH03-004-1102-1112</devId>'.
				'<timeOffset>-14400</timeOffset>'.
				'<mode>1</mode>'.
				'<measurements>'.
					'<groupid>7</groupid>'.
					'<measure>'.
						'<id>'.(time()-1).'</id>'.
						'<time>'.(time()-1).'</time>'.
						'<numConcentration>343219.875</numConcentration>'.
						'<avgParticleSize>48.543694</avgParticleSize>'.
						'<airPollutionIndex>5.04341</airPollutionIndex>'.
					'</measure>'.
					'<measure>'.
						'<id>'.time().'</id>'.
						'<time>'.time().'</time>'.
						'<numConcentration>356380</numConcentration>'.
						'<avgParticleSize>47.39357</avgParticleSize>'.
						'<airPollutionIndex>5.055265</airPollutionIndex>'.
					'</measure>'.
				'</measurements>'.
			'</nanoreporter>';

 
 
$URL = "https://myairmyhealth.medicalaffairs.philips.com/nanotracer/SH03-004-1102-1112";
#$URL = "http://localhost:3000/nanotracer/SH03-004-1102-1112";

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
