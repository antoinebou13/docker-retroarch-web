# Run RetroArch Web Player in a container
#
# docker run --rm -it -p 8080:80 retroarch-web-nightly
#
FROM debian:buster

LABEL maintainer "Antoine Boucher <antoine.bou13@gmail.com>"

RUN apt-get update && apt-get install -y \
	ca-certificates \
	unzip \
	sed \
	p7zip-full \
	coffeescript \
	xz-utils \
	nginx \
	wget \
	vim \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# https://github.com/libretro/RetroArch/tree/master/pkg/emscripten
# https://buildbot.libretro.com/nightly/

ENV ROOT_WWW_PATH /var/www/html

RUN cd ${ROOT_WWW_PATH} \
	&& wget https://buildbot.libretro.com/nightly/emscripten/$(date -d "yesterday" '+%Y-%m-%d')_RetroArch.7z \
	&& 7z e -y $(date -d "yesterday" '+%Y-%m-%d')_RetroArch.7z \
    && cp canvas.png media/canvas.png \
	&& chmod +x indexer \
	&& mkdir -p ${ROOT_WWW_PATH}/assets/frontend \
	&& mkdir -p ${ROOT_WWW_PATH}/assets/cores \
	&& mkdir -p ${ROOT_WWW_PATH}/assets/cores/retroarch \
	&& cd ${ROOT_WWW_PATH}/assets/frontend \
	&& wget https://buildbot.libretro.com/assets/frontend/bundle.zip \
	&& unzip bundle.zip -d bundle \
	&& cd ${ROOT_WWW_PATH}/assets/frontend/bundle \
	&& ../../../indexer > .index-xhr \
	&& cd ${ROOT_WWW_PATH}/assets/cores \
	&& wget -m -np -c -U "/var/www/html/assets/cores/NES/eye01" -R "index.html*" "https://the-eye.eu/public/rom/NES/"  \
	&& wget -m -np -c -U "/var/www/html/assets/cores/SNES/eye01" -R "index.html*" "https://the-eye.eu/public/rom/SNES/" \
	&& wget -m -np -c -U "/var/www/html/assets/cores/GB/eye01" -R "index.html*" "https://the-eye.eu/public/rom/Nintendo%20Gameboy/"  \
	&& wget -m -np -c -U "/var/www/html/assets/cores/GBA/eye01" -R "index.html*" "https://the-eye.eu/public/rom/Nintendo%20Gameboy%20Advance/" \
	&& wget -m -np -c -U "/var/www/html/assets/cores/GBC/eye01" -R "index.html*" "https://the-eye.eu/public/rom/Nintendo%20Gameboy%20Color/"  \
	&& wget -m -np -c -U "/var/www/html/assets/cores/SegaGenesis/eye01" -R "index.html*" "https://the-eye.eu/public/rom/Sega%20Genesis/" \
 	&& ../../indexer > .index-xhr \
	&& rm -rf ${ROOT_WWW_PATH}/RetroArch.7z \
	&& rm -rf ${ROOT_WWW_PATH}/assets/frontend/bundle.zip 
	
COPY sort_mkdir.sh ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/
RUN mv ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/Nintendo\ Gameboy/ ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/NintendoGameboy \
   && mv ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/Nintendo\ Gameboy\ Advance/ ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/NintendoGameboyAdvance \
   && mv ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/Nintendo\ Gameboy\ Color/ ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/NintendoGameboyColor \
   && mv ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/Sega\ Genesis/ ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/SegaGenesis \
   && bash ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/sort_mkdir.sh ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/NES/ \
   && bash ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/sort_mkdir.sh ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/SNES/ \
   && bash ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/sort_mkdir.sh ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/NintendoGameboy/ \
   && bash ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/sort_mkdir.sh ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/NintendoGameboyAdvance/ \
   && bash ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/sort_mkdir.sh ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/NintendoGameboyColor/ \
   && bash ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/sort_mkdir.sh ${ROOT_WWW_PATH}/assets/cores/the-eye.eu/public/rom/SegaGenesis/ \
   && cd ${ROOT_WWW_PATH}/assets/cores \
   && ../../indexer > .index-xhr

COPY index.html ${ROOT_WWW_PATH}/index.html

RUN cd ${ROOT_WWW_PATH}/assets/cores \
   && ../../indexer > .index-xhr

WORKDIR ${ROOT_WWW_PATH}

EXPOSE 80

COPY entrypoint.sh /

CMD [ "sh", "/entrypoint.sh"]
