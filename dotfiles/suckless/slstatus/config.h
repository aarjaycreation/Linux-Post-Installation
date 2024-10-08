/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/*

function            	description                     argument
battery_perc        	battery percentage              battery name (BAT0)
battery_remaining   	battery remaining HH:MM         battery name (BAT0)
battery_state       	battery charging state          battery name (BAT0)
cat                 	read arbitrary file             path
cpu_freq            	cpu frequency in MHz            NULL
cpu_perc            	cpu usage in percent            NULL
datetime            	date and time                   format string (%F %T)
disk_free           	free disk space in GB           mountpoint path (/)
disk_perc           	disk usage in percent           mountpoint path (/)
disk_total          	total disk space in GB          mountpoint path (/)
disk_used           	used disk space in GB           mountpoint path (/)
entropy             	available entropy               NULL
gid                 	GID of current user             NULL
hostname            	hostname                        NULL
ipv4                	IPv4 address                    interface name (eth0)
ipv6               		IPv6 address                    interface name (eth0)
kernel_release     		`uname -r`                      NULL
keyboard_indicators 	caps/num lock indicators        format string (c?n?)
keymap              	layout (variant) of current     NULL
load_avg            	load average                    NULL
netspeed_rx         	receive network speed           interface name (wlan0)
netspeed_tx         	transfer network speed          interface name (wlan0)
num_files          		number of files in a directory  path
ram_free           		free memory in GB               NULL
ram_perc           		memory usage in percent         NULL
ram_total          		total memory size in GB         NULL
ram_used            	used memory in GB               NULL
run_command         	custom shell command            command (echo foo)
swap_free          		free swap in GB                 NULL
swap_perc          		swap usage in percent           NULL
swap_total          	total swap size in GB           NULL
swap_used           	used swap in GB                 NULL
temp                	temperature in degree celsius   sensor file
uid                 	UID of current user             NULL
uptime              	system uptime                   NULL
username            	username of current user        NULL
vol_perc            	OSS/ALSA volume in percent      mixer file (/dev/mixer)
wifi_essid          	WiFi ESSID                      interface name (wlan0)
wifi_perc           	WiFi signal in percent          interface name (wlan0)
check_updates       	Check for updates               NULL

*/

static const struct arg args[] = {
/* 	function format  	argument */
	{ run_command, 		" %s", 					"/home/johan/.scripts/openweather" },
	{ cat, 				"  %s", 				"/home/johan/.scripts/avail_archupdates.txt" },
	{ run_command, 		"  %s", 				"/home/johan/.scripts/kernel" },
	{ run_command, 		"  %s", 				"/home/johan/.scripts/volume" },
	{ cpu_perc, 	 	"   %s%%", 			NULL },
	{ run_command, 		"   %s", 				"free -g | awk '/^Mem:/ {print $3 \"G/\" $2 \"G\"}'" },
	{ datetime, 		"  󰥔 %s", "%a %b %-d"  },
 	{ datetime, 		" %s", "%H:%M:%S " 		},	
};
