After copying the rui_logo_update repo folder to the /nepi_src/ folder on your nepi device

1) Create a logo with the correct aspect ratio

Logo (1004×254): ~4:1

2) Convert your PNG/JPG image to webp format. Many browser-based web tools can do this. E.g., 

https://cloudconvert.com/webp-converter

3) Rename the file:

logo.webp

4) Replace the logo.webp file in the file to the /nepi_src/rui_logo_update/ folder on your NEPI device's user storage drive

5) SSH into your nepi device and run these commands:

cd /mnt/nepi_storage/nepi_src/rui_logo_update/
cp logo.webp /opt/nepi/rui/src/rui_webserver/rui-app/src/logos/logo.webp
cd /opt/nepi/rui
source devenv.sh
cd src/rui_webserver/rui-app
npm run build


6) If you don't see any errors, refresh the NEPI device's RUI tab in your web browser.


