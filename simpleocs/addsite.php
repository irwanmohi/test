<?php
    /* SCRIPT TO GENERATE VIRTUAL HOST FILES IN /etc/apache2/sites-available/
	 * NEEDS TO BE RUN AS SUDO
    *****************************************************************************/

	//SERVER ADMIN
	$server_admin = 'pj@digitalbrands.com';

	//SITE DOMAIN
	$site_domain = 'pj.passprotect.me';

	//SITE PREFIXES
	$site_prefixes = array(
		'',     //DEFAULT HOME
		'db',   //DIGITALBRANDS
		'da',   //DATING ADVICE
		'pr',	//PRINTAHOLIC
		'cd',	//COUPONSDAILY
		'bc',	//BADCREDIT
		'cr',	//CARDRATES
		'gvs',  //GAINESVILLESHOWS
		'ha',   //HOSTINGADVICE
		'dc',   //DEALCRUNCH
	);

	//Set port to argv or default to 80
	$port = isset( $argv[1] ) ? $argv[1] : '80';

	//PATH TO VIRTUAL HOST FILES
	$path = '/etc/apache2/sites-available/';

	//LOOP THORUGH EACH SITE AND CREATE THE VIRTUAL HOST FILE
	$stdout = fopen('php://stdout', 'w');
	foreach( $site_prefixes as $site_prefix ) :
		$site_url = empty( $site_prefix ) ? $site_domain : $site_prefix . '.' . $site_domain;
		$file_handle = fopen( $path . $site_url, 'w' );
		fwrite( $stdout, "Writing file: $site_url\n" );
		fwrite( $file_handle,
"<VirtualHost *:$port>
	ServerAdmin $server_admin
	ServerName $site_url
	ServerAlias www.$site_url
	DocumentRoot /home/sites/$site_url/public_html
	ErrorLog /home/sites/$site_url/logs/error.log
	CustomLog /home/sites/$site_url/logs/access.log combined
		<Directory '/home/sites/$site_url/public_html'>
			AuthName 'Password Protected Area'
            AuthUserFile /home/.htpasswd
            AuthType Basic
            Require valid-user
			AllowOverride All
    	</Directory>
</VirtualHost>");
		fclose( $file_handle );
		unset( $file_handle );
	endforeach;
	fwrite( $stdout, "\nDONE!!\n" );
	fclose( $stdout );
?>
