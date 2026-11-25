<?php
// Wiki behaviour carried over from the Docker LocalSettings.php. The NixOS
// mediawiki module writes the paths, database, uploads and secret key
// settings; this file is required at the end of what it generates.

$wgLogos = [ '1x' => "$wgResourceBasePath/images/logo.png" ];

$wgEnableEmail = true;
$wgEnableUserEmail = false;
$wgEmergencyContact = "webmaster@erowiki.net";
$wgPasswordSender = "webmaster@erowiki.net";
$wgEnotifUserTalk = true;
$wgEnotifWatchlist = true;
$wgEmailAuthentication = true;

$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";
$wgMainCacheType = CACHE_ACCEL;
$wgUseInstantCommons = true;
$wgShowExceptionDetails = false;
$wgDeprecationReleaseLimit = "1.x";

$wgRightsPage = "";
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";

$wgGroupPermissions['*']['edit'] = false;

$wgDefaultSkin = "cosmos";
$wgVectorResponsive = true;
$wgVectorDefaultSkinVersion = '2';
$wgVectorShowSkinPreferences = true;

// The module loads ConfirmEdit itself; this adds the Turnstile captcha
// module. $wgTurnstileSiteKey / $wgTurnstileSecretKey come from secrets.php.
wfLoadExtension( 'ConfirmEdit/Turnstile' );

function makeFooterLink_Url( string $footerText, string $Url ) {
	return Html::element( 'a',
		[
			'href' => $Url,
			'rel' => 'noreferrer noopener',
		],
		$footerText
	);
}
$wgHooks['SkinAddFooterLinks'][] = function ( Skin $skin, string $key, array &$footerlinks ) {
	if ( $key === 'places' ) {
		$footerlinks['discord'] = makeFooterLink_Url( "Discord", "https://discord.com/invite/t6WyVJz" );
		$footerlinks['subscribestar_mc'] = makeFooterLink_Url( "SubscribeStar(MC)", "https://subscribestar.adult/magical-camp-games" );
		$footerlinks['patreon_mc'] = makeFooterLink_Url( 'Patreon(MC)', 'https://www.patreon.com/HLFMagicalCamp' );
		$footerlinks['kofi_lba'] = makeFooterLink_Url( 'Kofi(LBA)', 'https://ko-fi.com/W7W1JPDL' );
	}
};
