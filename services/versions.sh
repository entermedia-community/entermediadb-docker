#!/bin/bash
XML_FILE_TO_MODIFY=/opt/entermediadb/webapp/WEB-INF/base/mediadb/services/system/softwareversions.json
cat > $XML_FILE_TO_MODIFY <<EOF
{
    "response":
    {
        "status":"ok"
    },
    "results":[    
			{"name":"docker","version": "V_DOCKER"},
			{"name":"imagemagick","version": "V_IM"},
			{"name":"ghostscript","version": "V_GS"},
			{"name":"soffice","version": "V_SO"},
			{"name":"ffmpeg","version": "V_FFMPEG"}
			
            ]    
}
EOF
chown entermedia. $XML_FILE_TO_MODIFY 

V_IM=$(convert -version | head -n 1 | awk '{print $3}')
V_GS=$(gs -v | head -n 1 | awk '{print $3}')
V_SO=$(soffice --version -v | head -n 1 | awk '{print $2}')
V_FFMPEG=$(ffmpeg -version | head -n 1 | awk '{print $3}'i)
V_DOCKER=V_DOCKER_EXT

sed -i "s/V_IM/$V_IM/g" $XML_FILE_TO_MODIFY
sed -i "s/V_GS/$V_GS/g" $XML_FILE_TO_MODIFY
sed -i "s/V_SO/$V_SO/g" $XML_FILE_TO_MODIFY
sed -i "s/V_FFMPEG/$V_FFMPEG/g" $XML_FILE_TO_MODIFY
sed -i "s/V_DOCKER/$V_DOCKER/g" $XML_FILE_TO_MODIFY