module CartoDB
  module DataMover
    module LegacyFunctions
      # functions taken from https://github.com/postgis/postgis/blob/svn-trunk/utils/postgis_restore.pl.in#L473
      SIGNATURE_RE = /[\d\s;]*(?<type>(?:\S+\s?['class'|'family'|'aggregate'|'domain'|'function'|'cast'|'type']*))\s+(?:[^\s]\s+)?(?<name>[^\(]+)\s*(?:\((?<arguments>.*)\))?/i
      LEGACY_FUNCTIONS = [
        'AGGREGATE accum(geometry)',
        'AGGREGATE accum_old(geometry)',
        'AGGREGATE collect(geometry)',
        'AGGREGATE extent3d(geometry)',
        'AGGREGATE extent(geometry)',
        'AGGREGATE geomunion(geometry)',
        'AGGREGATE geomunion_old(geometry)',
        'AGGREGATE makeline(geometry)',
        'AGGREGATE memcollect(geometry)',
        'AGGREGATE memgeomunion(geometry)',
        'AGGREGATE polygonize(geometry)',
        'AGGREGATE st_3dextent(geometry)',
        'AGGREGATE st_accum(geometry)',
        'AGGREGATE st_accum_old(geometry)',
        'AGGREGATE st_collect(geometry)',
        'AGGREGATE st_extent3d(geometry)',
        'AGGREGATE st_extent(geometry)',
        'AGGREGATE st_makeline(geometry)',
        'AGGREGATE st_memcollect(geometry)',
        'AGGREGATE st_memunion(geometry)',
        'AGGREGATE st_polygonize(geometry)',
        'AGGREGATE st_union(geometry)',
        'AGGREGATE st_union_old(geometry)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,integer)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,integer,text)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,text)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,text,text)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,text,text,text)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,text,text,text,double precision)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,text,text,text,double precision,text,text,text,double precision)',
         # PG12_DEPRECATED
         'AGGREGATE st_union(raster,text,text,text,double precision,text,text,text,double precision,text,text,text,double precision)',
        'AGGREGATE topoelementarray_agg(topoelement)',
        'CAST CAST (boolean AS text)',
        'CAST CAST (bytea AS public.geography)',
        'CAST CAST (bytea AS public.geometry)',
        'CAST CAST (public.box2d AS public.box3d)',
        'CAST CAST (public.box2d AS public.geometry)',
        'CAST CAST (public.box3d AS box)',
        'CAST CAST (public.box3d AS public.box2d)',
        'CAST CAST (public.box3d AS public.geometry)',
        'CAST CAST (public.box3d_extent AS public.box2d)',
        'CAST CAST (public.box3d_extent AS public.box3d)',
        'CAST CAST (public.box3d_extent AS public.geometry)',
        'CAST CAST (public.chip AS public.geometry)',
        'CAST CAST (public.geography AS bytea)',
        'CAST CAST (public.geography AS public.geography)',
        'CAST CAST (public.geography AS public.geometry)',
        'CAST CAST (public.geometry AS box)',
        'CAST CAST (public.geometry AS bytea)',
        'CAST CAST (public.geometry AS public.box2d)',
        'CAST CAST (public.geometry AS public.box3d)',
        'CAST CAST (public.geometry AS public.geography)',
        'CAST CAST (public.geometry AS public.geometry)',
        'CAST CAST (public.geometry AS text)',
         # PG12_DEPRECATED
         'CAST CAST (public.raster AS box2d)',
         # PG12_DEPRECATED
         'CAST CAST (public.raster AS bytea)',
         # PG12_DEPRECATED
         'CAST CAST (public.raster AS public.box2d)',
         # PG12_DEPRECATED
         'CAST CAST (public.raster AS public.box3d)',
         # PG12_DEPRECATED
         'CAST CAST (public.raster AS public.geometry)',
         # PG12_DEPRECATED
         'CAST CAST (raster AS bytea)',
         # PG12_DEPRECATED
         'CAST CAST (raster AS geometry)',
        'CAST CAST (text AS public.geometry)',
        'CAST CAST (topology.topogeometry AS geometry)',
        'CAST CAST (topology.topogeometry AS public.geometry)',
        'COMMENT AGGREGATE st_3dextent(geometry)',
        'COMMENT AGGREGATE st_accum(geometry)',
        'COMMENT AGGREGATE st_collect(geometry)',
        'COMMENT AGGREGATE st_extent3d(geometry)',
        'COMMENT AGGREGATE st_extent(geometry)',
        'COMMENT AGGREGATE st_makeline(geometry)',
        'COMMENT AGGREGATE st_memunion(geometry)',
        'COMMENT AGGREGATE st_polygonize(geometry)',
        'COMMENT AGGREGATE st_union(geometry)',
         # PG12_DEPRECATED
         'COMMENT AGGREGATE st_union(raster)',
         # PG12_DEPRECATED
         'COMMENT AGGREGATE st_union(raster,integer)',
         # PG12_DEPRECATED
         'COMMENT AGGREGATE st_union(raster,integer,text)',
         # PG12_DEPRECATED
         'COMMENT AGGREGATE st_union(raster,text)',
        'COMMENT AGGREGATE topoelementarray_agg(topoelement)',
        'COMMENT DOMAIN topoelement',
        'COMMENT DOMAIN topoelementarray',
        'COMMENT FUNCTION addauth(text)',
        'COMMENT FUNCTION addedge(character varying,aline public.geometry)',
        'COMMENT FUNCTION addedge(character varying,public.geometry)',
        'COMMENT FUNCTION addface(character varying,apoly public.geometry,boolean)',
        'COMMENT FUNCTION addgeometrycolumn(varying,schema_namecharacter varying,character varying,column_namecharacter varying,new_srid_ininteger,new_typecharacter varying,new_diminteger,use_typmodboolean)',
        'COMMENT FUNCTION addgeometrycolumn(character varying,character varying,character varying,character varying,integer,character varying,integer)',
        'COMMENT FUNCTION addgeometrycolumn(character varying,character varying,character varying,integer,character varying,integer)',
        'COMMENT FUNCTION addgeometrycolumn(character varying,character varying,integer,character varying,integer)',
        'COMMENT FUNCTION addgeometrycolumn(character varying,character varying,character varying,integer,character varying,integer,boolean)',
        'COMMENT FUNCTION addgeometrycolumn(character varying,character varying,integer,character varying,integer,boolean)',
        'COMMENT FUNCTION addnode(character varying,apoint public.geometry,allowedgesplitting boolean,setcontainingface boolean)',
        'COMMENT FUNCTION addnode(varying,public.geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION addrasterconstraints(rastschema name,rasttable name,rastcolumn name,srid boolean,scale_x boolean,scale_y boolean,blocksize_x boolean,blocksize_y boolean,same_alignment boolean,regular_blocking boolean,num_bands boolean,pixel_types boolean,nodata_values boolean,extent boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION addrasterconstraints(rastschema name,rasttable name,rastcolumn name,variadic constraints text[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION addrasterconstraints(rasttable name,rastcolumn name,srid boolean,scale_x boolean,scale_y boolean,blocksize_x boolean,blocksize_y boolean,same_alignment boolean,regular_blocking boolean,num_bands boolean,pixel_types boolean,nodata_values boolean,extent boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION addrasterconstraints(rasttable name,rastcolumn name,variadic constraints text[])',
        'COMMENT FUNCTION addtopogeometrycolumn(character varying,character varying,character varying,character varying,character varying)',
        'COMMENT FUNCTION addtopogeometrycolumn(character varying,character varying,character varying,character varying,character varying,integer)',
        'COMMENT FUNCTION addtopogeometrycolumn(character varying,character varying,character varying,character varying,character varying,integer)',
        'COMMENT FUNCTION asgml(tgtopogeometry)',
        'COMMENT FUNCTION asgml(tgtopogeometry,nsprefix_in text,precision_in integer,options_in integer,visitedtable regclass,idprefix text,gmlver integer)',
        'COMMENT FUNCTION asgml(tgtopogeometry,nsprefix text)',
        'COMMENT FUNCTION asgml(tgtopogeometry,nsprefix text,prec integer,options integer,visitedtable regclass,idprefix text)',
        'COMMENT FUNCTION asgml(tgtopogeometry,nsprefix text,prec integer,options integer,vis regclass)',
        'COMMENT FUNCTION asgml(tgtopogeometry,nsprefix text,prec integer,opts integer)',
        'COMMENT FUNCTION asgml(tgtopogeometry,visitedtable regclass)',
        'COMMENT FUNCTION asgml(tgtopogeometry,visitedtable regclass,nsprefix text)',
        'COMMENT FUNCTION box2d(geometry)',
        'COMMENT FUNCTION box3d(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION box3d(raster)',
        'COMMENT FUNCTION checkauth(text,text)',
        'COMMENT FUNCTION checkauth(text,text,text)',
        'COMMENT FUNCTION copytopology(character varying,character varying)',
        'COMMENT FUNCTION createtopogeom(character varying,integer,integer,topoelementarray)',
        'COMMENT FUNCTION createtopogeom(character varying,tg_type integer,layer_id integer)',
        'COMMENT FUNCTION createtopogeom(character varying,tg_type integer,layer_id integer,tg_objs topoelementarray)',
        'COMMENT FUNCTION createtopology(character varying,integer,double precision,boolean)',
        'COMMENT FUNCTION createtopology(character varying)',
        'COMMENT FUNCTION createtopology(character varying,integer)',
        'COMMENT FUNCTION createtopology(character varying,sridinteger,precdouble precision)',
        'COMMENT FUNCTION disablelongtransactions()',
        'COMMENT FUNCTION dropgeometrycolumn(character varying,character varying,character varying,character varying)',
        'COMMENT FUNCTION dropgeometrycolumn(character varying,character varying)',
        'COMMENT FUNCTION dropgeometrycolumn(character varying,character varying,character varying)',
        'COMMENT FUNCTION dropgeometrycolumn(character varying,character varying,character varying,character varying)',
        'COMMENT FUNCTION dropgeometrycolumn(character varying,character varying,character varying)',
        'COMMENT FUNCTION dropgeometrycolumn(character varying,character varying)',
        'COMMENT FUNCTION dropgeometrytable(character varying,character varying,character varying)',
        'COMMENT FUNCTION dropgeometrytable(character varying)',
        'COMMENT FUNCTION dropgeometrytable(character varying,character varying)',
        'COMMENT FUNCTION dropgeometrytable(character varying,character varying,character varying)',
        'COMMENT FUNCTION dropgeometrytable(echaracter varying,character varying)',
        'COMMENT FUNCTION dropgeometrytable(character varying)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION droprasterconstraints(rastschema name,rasttable name,rastcolumn name,variadic constraints text[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION droprasterconstraints(rasttablename,rastcolumnname,sridboolean,scale_xboolean,scale_yboolean,blocksize_xboolean,blocksize_yboolean,same_alignmentboolean,regular_blockingboolean,num_bandsboolean,pixel_typesboolean,nodata_valuesboolean,extentboolean)',
        'COMMENT FUNCTION droptopogeometrycolumn(character varying,character varying,character varying)',
        'COMMENT FUNCTION droptopogeometrycolumn(schema character varying,tbl character varying,col character varying)',
        'COMMENT FUNCTION droptopology(atopology character varying)',
        'COMMENT FUNCTION droptopology(character varying)',
        'COMMENT FUNCTION enablelongtransactions()',
        'COMMENT FUNCTION find_srid(character varying,character varying,character varying)',
        'COMMENT FUNCTION geometrytype(geometry)',
        'COMMENT FUNCTION getedgebypoint(atopologycharacter varying,apointpublic.geometry,tol1double precision)',
        'COMMENT FUNCTION getfacebypoint(atopologycharacter varying,apointpublic.geometry,tol1double precision)',
        'COMMENT FUNCTION getnodebypoint(atopologycharacter varying,apointpublic.geometry,tol1double precision)',
        'COMMENT FUNCTION gettopogeomelementarray(character varying,integer,integer)',
        'COMMENT FUNCTION gettopogeomelementarray(tg topogeometry)',
        'COMMENT FUNCTION gettopogeomelementarray(topogeometry)',
        'COMMENT FUNCTION gettopogeomelementarray(character varying,layer_id integer,tgid integer)',
        'COMMENT FUNCTION gettopogeomelements(character varying,integer,integer)',
        'COMMENT FUNCTION gettopogeomelements(tg topogeometry)',
        'COMMENT FUNCTION gettopogeomelements(topogeometry)',
        'COMMENT FUNCTION gettopogeomelements(character varying,layerid integer,tgid integer)',
        'COMMENT FUNCTION gettopologyid(character varying)',
        'COMMENT FUNCTION gettopologyid(character varying)',
        'COMMENT FUNCTION gettopologyname(integer)',
        'COMMENT FUNCTION gettopologyname(topoid integer)',
        'COMMENT FUNCTION lockrow(text,text,text)',
        'COMMENT FUNCTION lockrow(text,text,text,text,timestampwithouttimezone)',
        'COMMENT FUNCTION lockrow(text,text,text,timestampwithouttimezone)',
        'COMMENT FUNCTION polygonize(character varying)',
        'COMMENT FUNCTION populate_geometry_columns()',
        'COMMENT FUNCTION populate_geometry_columns(tbl_oidoid)',
        'COMMENT FUNCTION populate_geometry_columns(tbl_oidoid,use_typmodboolean)',
        'COMMENT FUNCTION populate_geometry_columns(use_typmodboolean)',
        'COMMENT FUNCTION postgis_addbbox(geometry)',
        'COMMENT FUNCTION postgis_dropbbox(geometry)',
        'COMMENT FUNCTION postgis_full_version()',
        'COMMENT FUNCTION postgis_geos_version()',
        'COMMENT FUNCTION postgis_hasbbox(geometry)',
        'COMMENT FUNCTION postgis_lib_build_date()',
        'COMMENT FUNCTION postgis_lib_version()',
        'COMMENT FUNCTION postgis_libxml_version()',
        'COMMENT FUNCTION postgis_proj_version()',
         # PG12_DEPRECATED
         'COMMENT FUNCTION postgis_raster_lib_build_date()',
         # PG12_DEPRECATED
         'COMMENT FUNCTION postgis_raster_lib_version()',
        'COMMENT FUNCTION postgis_scripts_build_date()',
        'COMMENT FUNCTION postgis_scripts_installed()',
        'COMMENT FUNCTION postgis_scripts_released()',
        'COMMENT FUNCTION postgis_uses_stats()',
        'COMMENT FUNCTION postgis_version()',
        'COMMENT FUNCTION probe_geometry_columns()',
        'COMMENT FUNCTION st_3dclosestpoint(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_3dclosestpoint(geometry,geometry)',
        'COMMENT FUNCTION st_3ddfullywithin(geom1 geometry,geom2 geometry,double precision)',
        'COMMENT FUNCTION st_3ddfullywithin(geometry,geometry,double precision)',
        'COMMENT FUNCTION st_3ddistance(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_3ddistance(geometry,geometry)',
        'COMMENT FUNCTION st_3ddwithin(geom1 geometry,geom2 geometry,double precision)',
        'COMMENT FUNCTION st_3ddwithin(geometry,geometry,double precision)',
        'COMMENT FUNCTION st_3dintersects(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_3dintersects(geometry,geometry)',
        'COMMENT FUNCTION st_3dlength(geometry)',
        'COMMENT FUNCTION st_3dlength_spheroid(geometry,spheroid)',
        'COMMENT FUNCTION st_3dlongestline(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_3dlongestline(geometry,geometry)',
        'COMMENT FUNCTION st_3dmakebox(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_3dmakebox(geometry,geometry)',
        'COMMENT FUNCTION st_3dmaxdistance(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_3dmaxdistance(geometry,geometry)',
        'COMMENT FUNCTION st_3dperimeter(geometry)',
        'COMMENT FUNCTION st_3dshortestline(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_3dshortestline(geometry,geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_addband(rast raster,indexinteger,pixeltypetext,initialvaluedouble precision,nodatavaldouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_addband(rast raster,pixeltypetext,initialvaluedouble precision,nodatavaldouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_addband(torast raster,fromrast raster,frombandinteger,torastindexinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_addband(torast raster,fromrastsraster[],frombandinteger)',
        'COMMENT FUNCTION st_addbbox(geometry)',
        'COMMENT FUNCTION st_addedgemodface(atopologycharacter varying,anodeinteger,anothernodeinteger,acurvepublic.geometry)',
        'COMMENT FUNCTION st_addedgenewfaces(atopologycharacter varying,anodeinteger,anothernodeinteger,acurvepublic.geometry)',
        'COMMENT FUNCTION st_addisoedge(atopologycharacter varying,anodeinteger,anothernodeinteger,acurvepublic.geometry)',
        'COMMENT FUNCTION st_addisonode(atopology character varying,aface integer,apoint public.geometry)',
        'COMMENT FUNCTION st_addisonode(character varying,integer,public.geometry)',
        'COMMENT FUNCTION st_addmeasure(geometry,double precision,double precision)',
        'COMMENT FUNCTION st_addpoint(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_addpoint(geom1 geometry,geom2 geometry,integer)',
        'COMMENT FUNCTION st_addpoint(geometry,geometry)',
        'COMMENT FUNCTION st_addpoint(geometry,geometry,integer)',
        'COMMENT FUNCTION st_affine(geometry,double precision,double precision,double precision,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_affine(geometry,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_area(geoggeography,use_spheroidboolean)',
        'COMMENT FUNCTION st_area(geography)',
        'COMMENT FUNCTION st_area(geography,boolean)',
        'COMMENT FUNCTION st_area(geometry)',
        'COMMENT FUNCTION st_asbinary(geography)',
        'COMMENT FUNCTION st_asbinary(geography,text)',
        'COMMENT FUNCTION st_asbinary(geometry)',
        'COMMENT FUNCTION st_asbinary(geometry,text)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asbinary(raster)',
        'COMMENT FUNCTION st_asencodedpolyline(geometry)',
        'COMMENT FUNCTION st_asencodedpolyline(geometry,integer)',
        'COMMENT FUNCTION st_asewkb(geometry)',
        'COMMENT FUNCTION st_asewkb(geometry,text)',
        'COMMENT FUNCTION st_asewkt(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asgdalraster(rast raster,formattext,optionstext[],sridinteger)',
        'COMMENT FUNCTION st_asgeojson(geog geography,maxdecimaldigits integer,options integer)',
        'COMMENT FUNCTION st_asgeojson(geography)',
        'COMMENT FUNCTION st_asgeojson(geography,integer)',
        'COMMENT FUNCTION st_asgeojson(geography,integer,integer)',
        'COMMENT FUNCTION st_asgeojson(geometry)',
        'COMMENT FUNCTION st_asgeojson(geometry,integer)',
        'COMMENT FUNCTION st_asgeojson(geometry,integer,integer)',
        'COMMENT FUNCTION st_asgeojson(geom geometry,maxdecimaldigits integer,options integer)',
        'COMMENT FUNCTION st_asgeojson(gj_version integer,geog geography,maxdecimaldigits integer,options integer)',
        'COMMENT FUNCTION st_asgeojson(gj_version integer,geom geometry,maxdecimaldigits integer,options integer)',
        'COMMENT FUNCTION st_asgeojson(integer,geography)',
        'COMMENT FUNCTION st_asgeojson(integer,geography,integer)',
        'COMMENT FUNCTION st_asgeojson(integer,geography,integer,integer)',
        'COMMENT FUNCTION st_asgeojson(integer,geometry)',
        'COMMENT FUNCTION st_asgeojson(integer,geometry,integer)',
        'COMMENT FUNCTION st_asgeojson(integer,geometry,integer,integer)',
        'COMMENT FUNCTION st_asgml(geog geography,maxdecimaldigits integer,options integer)',
        'COMMENT FUNCTION st_asgml(geography)',
        'COMMENT FUNCTION st_asgml(geography,integer)',
        'COMMENT FUNCTION st_asgml(geography,integer,integer)',
        'COMMENT FUNCTION st_asgml(geometry)',
        'COMMENT FUNCTION st_asgml(geometry,integer)',
        'COMMENT FUNCTION st_asgml(geometry,integer,integer)',
        'COMMENT FUNCTION st_asgml(geom geometry,maxdecimaldigits integer,options integer)',
        'COMMENT FUNCTION st_asgml(integer,geography)',
        'COMMENT FUNCTION st_asgml(integer,geography,integer)',
        'COMMENT FUNCTION st_asgml(integer,geography,integer,integer)',
        'COMMENT FUNCTION st_asgml(integer,geography,integer,integer,text)',
        'COMMENT FUNCTION st_asgml(integer,geometry)',
        'COMMENT FUNCTION st_asgml(integer,geometry,integer)',
        'COMMENT FUNCTION st_asgml(integer,geometry,integer,integer)',
        'COMMENT FUNCTION st_asgml(integer,geometry,integer,integer,text)',
        'COMMENT FUNCTION st_asgml(version integer,geog geography,maxdecimaldigits integer,options integer,nprefix text)',
        'COMMENT FUNCTION st_asgml(version integer,geom geometry,maxdecimaldigits integer,options integer,nprefix text)',
        'COMMENT FUNCTION st_ashexewkb(geometry)',
        'COMMENT FUNCTION st_ashexewkb(geometry,text)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asjpeg(rast raster,nband integer,optionstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asjpeg(rast raster,nband integer,qualityinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asjpeg(rast raster,nbands integer[],optionstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asjpeg(rast raster,nbands integer[],qualityinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asjpeg(rast raster,optionstext[])',
        'COMMENT FUNCTION st_askml(geog geography,maxdecimaldigits integer)',
        'COMMENT FUNCTION st_askml(geography)',
        'COMMENT FUNCTION st_askml(geography,integer)',
        'COMMENT FUNCTION st_askml(geometry)',
        'COMMENT FUNCTION st_askml(geometry,integer)',
        'COMMENT FUNCTION st_askml(geom geometry,maxdecimaldigits integer)',
        'COMMENT FUNCTION st_askml(integer,geography)',
        'COMMENT FUNCTION st_askml(integer,geography,integer)',
        'COMMENT FUNCTION st_askml(integer,geography,integer,text)',
        'COMMENT FUNCTION st_askml(integer,geometry)',
        'COMMENT FUNCTION st_askml(integer,geometry,integer)',
        'COMMENT FUNCTION st_askml(integer,geometry,integer,text)',
        'COMMENT FUNCTION st_askml(version integer,geog geography,maxdecimaldigits integer,nprefix text)',
        'COMMENT FUNCTION st_askml(version integer,geom geometry,maxdecimaldigits integer,nprefix text)',
        'COMMENT FUNCTION st_aslatlontext(geometry)',
        'COMMENT FUNCTION st_aslatlontext(geometry,text)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_aspng(rast raster,nband integer,compressioninteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_aspng(rast raster,nband integer,optionstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_aspng(rast raster,nbands integer[],compressioninteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_aspng(rast raster,nbands integer[],optionstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_aspng(rast raster,optionstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,refraster,pixeltypetext,valuedouble precision,nodatavaldouble precision,touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,refraster,pixeltypetext[],valuedouble precision[],nodatavaldouble precision[],touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,scalexdouble precision,scaleydouble precision,gridxdouble precision,gridydouble precision,pixeltypetext,valuedouble precision,nodatavaldouble precision,skewxdouble precision,skewydouble precision,touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,scalexdouble precision,scaleydouble precision,gridxdouble precision,gridydouble precision,pixeltypetext[],valuedouble precision[],nodatavaldouble precision[],skewxdouble precision,skewydouble precision,touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,scalexdouble precision,scaleydouble precision,pixeltypetext,valuedouble precision,nodatavaldouble precision,upperleftxdouble precision,upperleftydouble precision,skewxdouble precision,skewydouble precision,touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,widthinteger,heightinteger,gridxdouble precision,gridydouble precision,pixeltypetext,valuedouble precision,nodatavaldouble precision,skewxdouble precision,skewydouble precision,touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,widthinteger,heightinteger,gridxdouble precision,gridydouble precision,pixeltypetext[],valuedouble precision[],nodatavaldouble precision[],skewxdouble precision,skewydouble precision,touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,widthinteger,heightinteger,pixeltypetext,valuedouble precision,nodatavaldouble precision,upperleftxdouble precision,upperleftydouble precision,skewxdouble precision,skewydouble precision,touchedboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_asraster(geomgeometry,widthinteger,heightinteger,pixeltypetext[],valuedouble precision[],nodatavaldouble precision[],upperleftxdouble precision,upperleftydouble precision,skewxdouble precision,skewydouble precision,touchedboolean)',
        'COMMENT FUNCTION st_assvg(geog geography,rel integer,maxdecimaldigits integer)',
        'COMMENT FUNCTION st_assvg(geography)',
        'COMMENT FUNCTION st_assvg(geography,integer)',
        'COMMENT FUNCTION st_assvg(geography,integer,integer)',
        'COMMENT FUNCTION st_assvg(geometry)',
        'COMMENT FUNCTION st_assvg(geometry,integer)',
        'COMMENT FUNCTION st_assvg(geometry,integer,integer)',
        'COMMENT FUNCTION st_assvg(geom geometry,rel integer,maxdecimaldigits integer)',
        'COMMENT FUNCTION st_astext(geography)',
        'COMMENT FUNCTION st_astext(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_astiff(rast raster,compressiontext,sridinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_astiff(rast raster,nbands integer[],compressiontext,sridinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_astiff(rast raster,nbands integer[],optionstext[],sridinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_astiff(rast raster,optionstext[],sridinteger)',
        'COMMENT FUNCTION st_asx3d(geom geometry,maxdecimaldigits integer,options integer)',
        'COMMENT FUNCTION st_asx3d(geomgeometry,precinteger)',
        'COMMENT FUNCTION st_azimuth(geog1 geography,geog2 geography)',
        'COMMENT FUNCTION st_azimuth(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_azimuth(geometry,geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_bandisnodata(rast raster,bandinteger,forcecheckingboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_bandisnodata(rast raster,forcechecking boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_bandmetadata(rast raster,bandinteger,OUT pixeltype text,OUT hasnodata boolean,OUT nodatavalue double precision,OUT isoutdb boolean,OUT path text)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_bandnodatavalue(rast raster,bandinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_bandpath(rast raster,bandinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_bandpixeltype(rast raster,bandinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_band(rast raster,nband integer)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_band(rast raster,nbands integer[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_band(rast raster,nbandstext,delimitercharacter)',
        'COMMENT FUNCTION st_bdmpolyfromtext(text,integer)',
        'COMMENT FUNCTION st_bdpolyfromtext(text,integer)',
        'COMMENT FUNCTION st_boundary(geometry)',
        'COMMENT FUNCTION st_box2dfromgeohash(text)',
        'COMMENT FUNCTION st_box2dfromgeohash(text,integer)',
        'COMMENT FUNCTION st_box2d(geometry)',
        'COMMENT FUNCTION st_box3d(geometry)',
        'COMMENT FUNCTION st_buffer(geography,double precision)',
        'COMMENT FUNCTION st_buffer(geometry,double precision)',
        'COMMENT FUNCTION st_buffer(geometry,double precision,integer)',
        'COMMENT FUNCTION st_buffer(geometry,double precision,text)',
        'COMMENT FUNCTION st_buildarea(geometry)',
        'COMMENT FUNCTION st_centroid(geometry)',
        'COMMENT FUNCTION st_changeedgegeom(atopologycharacter varying,anedgeinteger,acurvepublic.geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_clip(rast raster,band integer,geom geometry,crop boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_clip(rast raster,band integer,geom geometry,nodata double precision,trimraster boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_clip(rast raster,band integer,geom geometry,trimraster boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_clip(rast raster,geom geometry,crop boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_clip(rast raster,geom geometry,nodata double precision,trimraster boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_clip(rast raster,geom geometry,trimraster boolean)',
        'COMMENT FUNCTION st_closestpoint(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_closestpoint(geometry,geometry)',
        'COMMENT FUNCTION st_collect(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_collect(geometry[])',
        'COMMENT FUNCTION st_collect(geometry,geometry)',
        'COMMENT FUNCTION st_collectionextract(geometry,integer)',
        'COMMENT FUNCTION st_concavehull(param_geomgeometry,param_pctconvexdouble precision,param_allow_holesboolean)',
        'COMMENT FUNCTION st_contains(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_contains(geometry,geometry)',
        'COMMENT FUNCTION st_containsproperly(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_containsproperly(geometry,geometry)',
        'COMMENT FUNCTION st_convexhull(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_convexhull(raster)',
        'COMMENT FUNCTION st_coorddim(geometry)',
        'COMMENT FUNCTION st_coorddim(geometry geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_count(rastertabletext,rastercolumntext,exclude_nodata_valueboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_count(rastertabletext,rastercolumntext,nband integer,exclude_nodata_valueboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_count(rast raster,exclude_nodata_valueboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_count(rast raster,nband integer,exclude_nodata_valueboolean)',
        'COMMENT FUNCTION st_coveredby(geography,geography)',
        'COMMENT FUNCTION st_coveredby(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_coveredby(geometry,geometry)',
        'COMMENT FUNCTION st_covers(geography,geography)',
        'COMMENT FUNCTION st_covers(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_covers(geometry,geometry)',
        'COMMENT FUNCTION st_createtopogeo(atopologycharacter varying,acollectionpublic.geometry)',
        'COMMENT FUNCTION st_crosses(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_crosses(geometry,geometry)',
        'COMMENT FUNCTION st_curvetoline(geometry)',
        'COMMENT FUNCTION st_curvetoline(geometry,integer)',
        'COMMENT FUNCTION st_dfullywithin(geom1 geometry,geom2 geometry,double precision)',
        'COMMENT FUNCTION st_dfullywithin(geometry,geometry,double precision)',
        'COMMENT FUNCTION st_difference(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_difference(geometry,geometry)',
        'COMMENT FUNCTION st_dimension(geometry)',
        'COMMENT FUNCTION st_disjoint(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_disjoint(geometry,geometry)',
        'COMMENT FUNCTION st_distance(geography,geography)',
        'COMMENT FUNCTION st_distance(geography,geography,boolean)',
        'COMMENT FUNCTION st_distance(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_distance(geometry,geometry)',
        'COMMENT FUNCTION st_distance_sphere(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_distance_sphere(geometry,geometry)',
        'COMMENT FUNCTION st_distance_spheroid(geom1 geometry,geom2 geometry,spheroid)',
        'COMMENT FUNCTION st_distance_spheroid(geometry,geometry,spheroid)',
        'COMMENT FUNCTION st_dropbbox(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_dumpaspolygons(rast raster,bandinteger)',
        'COMMENT FUNCTION st_dump(geometry)',
        'COMMENT FUNCTION st_dumppoints(geometry)',
        'COMMENT FUNCTION st_dumprings(geometry)',
        'COMMENT FUNCTION st_dwithin(geography,geography,double precision)',
        'COMMENT FUNCTION st_dwithin(geography,geography,double precision,boolean)',
        'COMMENT FUNCTION st_dwithin(geom1 geometry,geom2 geometry,double precision)',
        'COMMENT FUNCTION st_dwithin(geometry,geometry,double precision)',
        'COMMENT FUNCTION st_endpoint(geometry)',
        'COMMENT FUNCTION st_envelope(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_envelope(raster)',
        'COMMENT FUNCTION st_equals(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_equals(geometry,geometry)',
        'COMMENT FUNCTION st_estimated_extent(text,text)',
        'COMMENT FUNCTION st_estimated_extent(text,text,text)',
        'COMMENT FUNCTION st_expand(box2d,double precision)',
        'COMMENT FUNCTION st_expand(box3d,double precision)',
        'COMMENT FUNCTION st_expand(geometry,double precision)',
        'COMMENT FUNCTION st_exteriorring(geometry)',
        'COMMENT FUNCTION st_flipcoordinates(geometry)',
        'COMMENT FUNCTION st_force_2d(geometry)',
        'COMMENT FUNCTION st_force_3d(geometry)',
        'COMMENT FUNCTION st_force_3dm(geometry)',
        'COMMENT FUNCTION st_force_3dz(geometry)',
        'COMMENT FUNCTION st_force_4d(geometry)',
        'COMMENT FUNCTION st_force_collection(geometry)',
        'COMMENT FUNCTION st_forcerhr(geometry)',
        'COMMENT FUNCTION st_frechetdistance(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_frechetdistance(geom1 geometry,geom2 geometry,double precision)',
        'COMMENT FUNCTION st_frechetdistance(geometry,geometry)',
        'COMMENT FUNCTION st_frechetdistance(geometry,geometry,double precision)',
        'COMMENT FUNCTION st_gdaldrivers(OUTidxinteger,OUTshort_nametext,OUTlong_nametext,OUTcreate_optionstext)',
        'COMMENT FUNCTION st_geogfromtext(text)',
        'COMMENT FUNCTION st_geogfromwkb(bytea)',
        'COMMENT FUNCTION st_geographyfromtext(text)',
        'COMMENT FUNCTION st_geohash(geometry)',
        'COMMENT FUNCTION st_geohash(geometry,integer)',
        'COMMENT FUNCTION st_geohash(geom geometry,maxchars integer)',
        'COMMENT FUNCTION st_geomcollfromtext(text)',
        'COMMENT FUNCTION st_geomcollfromtext(text,integer)',
        'COMMENT FUNCTION st_geometryfromtext(text)',
        'COMMENT FUNCTION st_geometryfromtext(text,integer)',
        'COMMENT FUNCTION st_geometryn(geometry,integer)',
        'COMMENT FUNCTION st_geometrytype(geometry)',
        'COMMENT FUNCTION st_geomfromewkb(bytea)',
        'COMMENT FUNCTION st_geomfromewkt(text)',
        'COMMENT FUNCTION st_geomfromgeohash(text)',
        'COMMENT FUNCTION st_geomfromgeohash(text,integer)',
        'COMMENT FUNCTION st_geomfromgeojson(text)',
        'COMMENT FUNCTION st_geomfromgml(text)',
        'COMMENT FUNCTION st_geomfromgml(text,integer)',
        'COMMENT FUNCTION st_geomfromkml(text)',
        'COMMENT FUNCTION st_geomfromtext(text)',
        'COMMENT FUNCTION st_geomfromtext(text,integer)',
        'COMMENT FUNCTION st_geomfromwkb(bytea)',
        'COMMENT FUNCTION st_geomfromwkb(bytea,integer)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_georeference(rast raster,formattext)',
        'COMMENT FUNCTION st_getfaceedges(character varying,face_idinteger)',
        'COMMENT FUNCTION st_getfacegeometry(character varying,afaceinteger)',
        'COMMENT FUNCTION st_gmltosql(text)',
        'COMMENT FUNCTION st_gmltosql(text,integer)',
        'COMMENT FUNCTION st_hasarc(geometry)',
        'COMMENT FUNCTION st_hasarc(geometry geometry)',
        'COMMENT FUNCTION st_hasbbox(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_hasnoband(rast raster,nband integer)',
        'COMMENT FUNCTION st_hausdorffdistance(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_hausdorffdistance(geom1 geometry,geom2 geometry,double precision)',
        'COMMENT FUNCTION st_hausdorffdistance(geometry,geometry)',
        'COMMENT FUNCTION st_hausdorffdistance(geometry,geometry,double precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_height(raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_hillshade(rast raster,band integer,pixeltype text,azimuth double precision,altitude double precision,max_bright double precision,elevation_scale double precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rastertabletext,rastercolumntext,nband integer,binsinteger,"right"boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rastertabletext,rastercolumntext,nband integer,binsinteger,widthdouble precision[],"right"boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rastertabletext,rastercolumntext,nband integer,exclude_nodata_valueboolean,binsinteger,"right"boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rastertabletext,rastercolumntext,nband integer,exclude_nodata_valueboolean,binsinteger,widthdouble precision[],"right"boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rast raster,nband integer,binsinteger,"right"boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rast raster,nband integer,binsinteger,widthdouble precision[],"right"boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rast raster,nband integer,exclude_nodata_valueboolean,binsinteger,"right"boolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_histogram(rast raster,nband integer,exclude_nodata_valueboolean,binsinteger,widthdouble precision[],"right"boolean)',
        'COMMENT FUNCTION st_inittopogeo(atopologycharacter varying)',
        'COMMENT FUNCTION st_interiorringn(geometry,integer)',
        'COMMENT FUNCTION st_intersection(geography,geography)',
        'COMMENT FUNCTION st_intersection(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_intersection(geometry,geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersection(geomingeometry,rast raster,bandinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersection(rast1raster,band1integer,geomgeometry,extenttypetext,otheruserfuncregprocedure)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersection(rast1raster,band1integer,geomgeometry,otheruserfuncregprocedure)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersection(rast1raster,geomgeometry,extenttypetext,otheruserfuncregprocedure)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersection(rast1raster,geomgeometry,otheruserfuncregprocedure)',
        'COMMENT FUNCTION st_intersects(geography,geography)',
        'COMMENT FUNCTION st_intersects(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_intersects(geometry,geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersects(geomgeometry,rast raster,nband integer)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersects(rast1raster,nband1integer,rast2raster,nband2integer)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersects(rast1raster,rast2raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_intersects(rast raster,nband integer,geomgeometry)',
        'COMMENT FUNCTION st_isclosed(geometry)',
        'COMMENT FUNCTION st_iscollection(geometry)',
        'COMMENT FUNCTION st_isempty(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_isempty(rast raster)',
        'COMMENT FUNCTION st_isring(geometry)',
        'COMMENT FUNCTION st_issimple(geometry)',
        'COMMENT FUNCTION st_isvaliddetail(geometry)',
        'COMMENT FUNCTION st_isvaliddetail(geometry,integer)',
        'COMMENT FUNCTION st_isvalid(geometry)',
        'COMMENT FUNCTION st_isvalid(geometry,integer)',
        'COMMENT FUNCTION st_isvalidreason(geometry)',
        'COMMENT FUNCTION st_isvalidreason(geometry,integer)',
        'COMMENT FUNCTION st_length2d(geometry)',
        'COMMENT FUNCTION st_length2d_spheroid(geometry,spheroid)',
        'COMMENT FUNCTION st_length3d(geometry)',
        'COMMENT FUNCTION st_length3d_spheroid(geometry,spheroid)',
        'COMMENT FUNCTION st_length(geoggeography,use_spheroidboolean)',
        'COMMENT FUNCTION st_length(geography)',
        'COMMENT FUNCTION st_length(geography,boolean)',
        'COMMENT FUNCTION st_length(geometry)',
        'COMMENT FUNCTION st_length_spheroid(geometry,spheroid)',
        'COMMENT FUNCTION st_linecrossingdirection(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_linecrossingdirection(geometry,geometry)',
        'COMMENT FUNCTION st_linefromencodedpolyline(text)',
        'COMMENT FUNCTION st_linefromencodedpolyline(text,integer)',
        'COMMENT FUNCTION st_linefrommultipoint(geometry)',
        'COMMENT FUNCTION st_linefromtext(text)',
        'COMMENT FUNCTION st_linefromtext(text,integer)',
        'COMMENT FUNCTION st_linefromwkb(bytea)',
        'COMMENT FUNCTION st_linefromwkb(bytea,integer)',
        'COMMENT FUNCTION st_line_interpolate_point(geometry,double precision)',
        'COMMENT FUNCTION st_line_locate_point(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_line_locate_point(geometry,geometry)',
        'COMMENT FUNCTION st_linemerge(geometry)',
        'COMMENT FUNCTION st_linestringfromwkb(bytea)',
        'COMMENT FUNCTION st_linestringfromwkb(bytea,integer)',
        'COMMENT FUNCTION st_line_substring(geometry,double precision,double precision)',
        'COMMENT FUNCTION st_linetocurve(geometry)',
        'COMMENT FUNCTION st_linetocurve(geometry geometry)',
        'COMMENT FUNCTION st_locate_along_measure(geometry,double precision)',
        'COMMENT FUNCTION st_locatebetweenelevations(geometry,double precision,double precision)',
        'COMMENT FUNCTION st_locatebetweenelevations(geometry geometry,fromelevation double precision,toelevation double precision)',
        'COMMENT FUNCTION st_locate_between_measures(geometry,double precision,double precision)',
        'COMMENT FUNCTION st_longestline(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_longestline(geometry,geometry)',
        'COMMENT FUNCTION st_makebox2d(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_makebox2d(geometry,geometry)',
        'COMMENT FUNCTION st_makebox3d(geometry,geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_makeemptyraster(rast raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_makeemptyraster(widthinteger,heightinteger,upperleftxdouble precision,upperleftydouble precision,pixelsizedouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_makeemptyraster(widthinteger,heightinteger,upperleftxdouble precision,upperleftydouble precision,scalexdouble precision,scaleydouble precision,skewxdouble precision,skewydouble precision,sridinteger)',
        'COMMENT FUNCTION st_makeenvelope(double precision,double precision,double precision,double precision,integer)',
        'COMMENT FUNCTION st_makeline(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_makeline(geometry[])',
        'COMMENT FUNCTION st_makeline(geometry,geometry)',
        'COMMENT FUNCTION st_makepoint(double precision,double precision)',
        'COMMENT FUNCTION st_makepoint(double precision,double precision,double precision)',
        'COMMENT FUNCTION st_makepoint(double precision,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_makepointm(double precision,double precision,double precision)',
        'COMMENT FUNCTION st_makepolygon(geometry)',
        'COMMENT FUNCTION st_makepolygon(geometry,geometry[])',
        'COMMENT FUNCTION st_makevalid(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebraexpr(rast1raster,band1integer,rast2raster,band2integer,expressiontext,pixeltypetext,extenttypetext,nodata1exprtext,nodata2exprtext,nodatanodatavaldouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebraexpr(rast1raster,rast2raster,expressiontext,pixeltypetext,extenttypetext,nodata1exprtext,nodata2exprtext,nodatanodatavaldouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebraexpr(rast raster,bandinteger,pixeltypetext,expressiontext,nodatavaldouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebraexpr(rast raster,pixeltypetext,expressiontext,nodatavaldouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafctngb(rast raster,bandinteger,pixeltypetext,ngbwidthinteger,ngbheightinteger,onerastngbuserfuncregprocedure,nodatamodetext,variadicargstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast1raster,band1integer,rast2raster,band2integer,tworastuserfuncregprocedure,pixeltypetext,extenttypetext,variadicuserargstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast1raster,rast2raster,tworastuserfuncregprocedure,pixeltypetext,extenttypetext,variadicuserargstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,bandinteger,onerastuserfuncregprocedure)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,bandinteger,onerastuserfuncregprocedure,variadicargstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,bandinteger,pixeltypetext,onerastuserfuncregprocedure)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,bandinteger,pixeltypetext,onerastuserfuncregprocedure,variadicargstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,onerastuserfuncregprocedure)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,onerastuserfuncregprocedure,variadicargstext[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,pixeltypetext,onerastuserfuncregprocedure)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_mapalgebrafct(rast raster,pixeltypetext,onerastuserfuncregprocedure,variadicargstext[])',
        'COMMENT FUNCTION st_maxdistance(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_max_distance(geometry,geometry)',
        'COMMENT FUNCTION st_maxdistance(geometry,geometry)',
        'COMMENT FUNCTION st_mem_size(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_metadata(rast raster,OUTupperleftxdouble precision,OUTupperleftydouble precision,OUTwidthinteger,OUTheightinteger,OUTscalexdouble precision,OUTscaleydouble precision,OUTskewxdouble precision,OUTskewydouble precision,OUTsridinteger,OUTnumbandsinteger)',
        'COMMENT FUNCTION st_m(geometry)',
        'COMMENT FUNCTION st_minimumboundingcircle(geometry)',
        'COMMENT FUNCTION st_minimumboundingcircle(inputgeomgeometry,segs_per_quarterinteger)',
        'COMMENT FUNCTION st_mlinefromtext(text)',
        'COMMENT FUNCTION st_mlinefromtext(text,integer)',
        'COMMENT FUNCTION st_modedgeheal(character varying,e1idinteger,e2idinteger)',
        'COMMENT FUNCTION st_modedgesplit(atopology character varying,anedge integer,apoint public.geometry)',
        'COMMENT FUNCTION st_modedgesplit(character varying,integer,public.geometry)',
        'COMMENT FUNCTION st_moveisonode(atopology character varying,anode integer,apoint public.geometry)',
        'COMMENT FUNCTION st_moveisonode(character varying,integer,public.geometry)',
        'COMMENT FUNCTION st_mpointfromtext(text)',
        'COMMENT FUNCTION st_mpointfromtext(text,integer)',
        'COMMENT FUNCTION st_mpolyfromtext(text)',
        'COMMENT FUNCTION st_mpolyfromtext(text,integer)',
        'COMMENT FUNCTION st_multi(geometry)',
        'COMMENT FUNCTION st_ndims(geometry)',
        'COMMENT FUNCTION st_newedgeheal(character varying,e1idinteger,e2idinteger)',
        'COMMENT FUNCTION st_newedgessplit(atopology character varying,anedge integer,apoint public.geometry)',
        'COMMENT FUNCTION st_newedgessplit(character varying,integer,public.geometry)',
        'COMMENT FUNCTION st_node(ggeometry)',
        'COMMENT FUNCTION st_npoints(geometry)',
        'COMMENT FUNCTION st_nrings(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_numbands(raster)',
        'COMMENT FUNCTION st_numgeometries(geometry)',
        'COMMENT FUNCTION st_numinteriorring(geometry)',
        'COMMENT FUNCTION st_numinteriorrings(geometry)',
        'COMMENT FUNCTION st_numpatches(geometry)',
        'COMMENT FUNCTION st_numpoints(geometry)',
        'COMMENT FUNCTION st_offsetcurve(linegeometry,distancedouble precision,paramstext)',
        'COMMENT FUNCTION st_orderingequals(geometrya geometry,geometryb geometry)',
        'COMMENT FUNCTION st_orderingequals(geometry,geometry)',
        'COMMENT FUNCTION st_overlaps(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_overlaps(geometry,geometry)',
        'COMMENT FUNCTION st_patchn(geometry,integer)',
        'COMMENT FUNCTION st_perimeter2d(geometry)',
        'COMMENT FUNCTION st_perimeter3d(geometry)',
        'COMMENT FUNCTION st_perimeter(geoggeography,use_spheroidboolean)',
        'COMMENT FUNCTION st_perimeter(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_pixelaspolygon(rast raster,bandinteger,xinteger,yinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_pixelaspolygon(rast raster,xinteger,yinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_pixelheight(raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_pixelwidth(raster)',
        'COMMENT FUNCTION st_point(double precision,double precision)',
        'COMMENT FUNCTION st_pointfromgeohash(text)',
        'COMMENT FUNCTION st_pointfromgeohash(text,integer)',
        'COMMENT FUNCTION st_pointfromtext(text)',
        'COMMENT FUNCTION st_pointfromtext(text,integer)',
        'COMMENT FUNCTION st_point_inside_circle(geometry,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_pointn(geometry,integer)',
        'COMMENT FUNCTION st_pointonsurface(geometry)',
        'COMMENT FUNCTION st_polygonfromtext(text)',
        'COMMENT FUNCTION st_polygonfromtext(text,integer)',
        'COMMENT FUNCTION st_polygon(geometry,integer)',
        'COMMENT FUNCTION st_polygonize(geometry[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_polygon(rast raster,bandinteger)',
        'COMMENT FUNCTION st_project(geog geography,distance double precision,azimuth double precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_quantile(rast raster,exclude_nodata_valueboolean,quantiledouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_quantile(rast raster,nband integer,exclude_nodata_valueboolean,quantiledouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_quantile(rast raster,nband integer,exclude_nodata_valueboolean,quantilesdouble precision[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_quantile(rast raster,nband integer,quantiledouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_quantile(rast raster,nband integer,quantilesdouble precision[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_quantile(rast raster,quantiledouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_quantile(rast raster,quantilesdouble precision[])',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_raster2worldcoordx(rast raster,xrinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_raster2worldcoordx(rast raster,xrinteger,yrinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_raster2worldcoordy(rast raster,xrinteger,yrinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_raster2worldcoordy(rast raster,yrinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_reclass(rast raster,nband integer,reclassexprtext,pixeltypetext,nodatavaldouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_reclass(rast raster,reclassexprtext,pixeltypetext)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_reclass(rast raster,variadicreclassargsetreclassarg[])',
        'COMMENT FUNCTION st_relate(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_relate(geom1 geometry,geom2 geometry,integer)',
        'COMMENT FUNCTION st_relate(geom1 geometry,geom2 geometry,text)',
        'COMMENT FUNCTION st_relate(geometry,geometry)',
        'COMMENT FUNCTION st_relate(geometry,geometry,integer)',
        'COMMENT FUNCTION st_relate(geometry,geometry,text)',
        'COMMENT FUNCTION st_relatematch(text,text)',
        'COMMENT FUNCTION st_remedgemodface(character varying,e1id integer)',
        'COMMENT FUNCTION st_remedgenewface(character varying,e1id integer)',
        'COMMENT FUNCTION st_removeisonode(atopology character varying,anode integer)',
        'COMMENT FUNCTION st_removeisonode(character varying,integer)',
        'COMMENT FUNCTION st_removepoint(geometry,integer)',
        'COMMENT FUNCTION st_removerepeatedpoints(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_resample(rast raster,refraster,algorithmtext,maxerrdouble precision,usescaleboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_resample(rast raster,refraster,usescaleboolean,algorithmtext,maxerrdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_resample(rast raster,sridinteger,scalexdouble precision,scaleydouble precision,gridxdouble precision,gridydouble precision,skewxdouble precision,skewydouble precision,algorithmtext,maxerrdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_resample(rast raster,widthinteger,heightinteger,sridinteger,gridxdouble precision,gridydouble precision,skewxdouble precision,skewydouble precision,algorithmtext,maxerrdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_rescale(rast raster,scalexdouble precision,scaleydouble precision,algorithmtext,maxerrdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_rescale(rast raster,scalexydouble precision,algorithmtext,maxerrdouble precision)',
        'COMMENT FUNCTION st_reverse(geometry)',
        'COMMENT FUNCTION st_rotate(geometry,double precision)',
        'COMMENT FUNCTION st_rotatex(geometry,double precision)',
        'COMMENT FUNCTION st_rotatey(geometry,double precision)',
        'COMMENT FUNCTION st_rotatez(geometry,double precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_rotation(raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_samealignment(rast1raster,rast2raster)',
        'COMMENT FUNCTION st_samealignment(ulx1double precision,uly1double precision,scalex1double precision,scaley1double precision,skewx1double precision,skewy1double precision,ulx2double precision,uly2double precision,scalex2double precision,scaley2double precision,skewx2double precision,skewy2double precision)',
        'COMMENT FUNCTION st_scale(geometry,double precision,double precision)',
        'COMMENT FUNCTION st_scale(geometry,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_scalex(raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_scaley(raster)',
        'COMMENT FUNCTION st_segmentize(geometry,double precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setbandisnodata(rast raster,bandinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setbandnodatavalue(rast raster,bandinteger,nodatavaluedouble precision,forcecheckingboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setbandnodatavalue(rast raster,nodatavaluedouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setgeoreference(rast raster,georeftext,formattext)',
        'COMMENT FUNCTION st_setpoint(geometry,integer,geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setrotation(rast raster,rotationdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setscale(rast raster,scaledouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setscale(rast raster,scalexdouble precision,scaleydouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setskew(rast raster,skewdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setskew(rast raster,skewxdouble precision,skewydouble precision)',
        'COMMENT FUNCTION st_setsrid(geometry,integer)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setsrid(rast raster,sridinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setupperleft(rast raster,upperleftxdouble precision,upperleftydouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setvalue(rast raster,bandinteger,ptgeometry,newvaluedouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setvalue(rast raster,bandinteger,xinteger,yinteger,newvaluedouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setvalue(rast raster,ptgeometry,newvaluedouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_setvalue(rast raster,xinteger,yinteger,newvaluedouble precision)',
        'COMMENT FUNCTION st_sharedpaths(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_sharedpaths(geometry,geometry)',
        'COMMENT FUNCTION st_shift_longitude(geometry)',
        'COMMENT FUNCTION st_shortestline(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_shortestline(geometry,geometry)',
        'COMMENT FUNCTION st_simplify(geometry,double precision)',
        'COMMENT FUNCTION st_simplifypreservetopology(geometry,double precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_skewx(raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_skewy(raster)',
        'COMMENT FUNCTION st_snap(geom1 geometry,geom2 geometry,double precision)',
        'COMMENT FUNCTION st_snap(geometry,geometry,double precision)',
        'COMMENT FUNCTION st_snaptogrid(geom1 geometry,geom2 geometry,double precision,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_snaptogrid(geometry,double precision)',
        'COMMENT FUNCTION st_snaptogrid(geometry,double precision,double precision)',
        'COMMENT FUNCTION st_snaptogrid(geometry,double precision,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_snaptogrid(geometry,geometry,double precision,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_split(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_split(geometry,geometry)',
        'COMMENT FUNCTION st_srid(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_srid(raster)',
        'COMMENT FUNCTION st_startpoint(geometry)',
        'COMMENT FUNCTION st_summary(geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_summarystats(rastertabletext,rastercolumntext,exclude_nodata_valueboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_summarystats(rastertabletext,rastercolumntext,nband integer,exclude_nodata_valueboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_summarystats(rast raster,exclude_nodata_valueboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_summarystats(rast raster,nband integer,exclude_nodata_valueboolean)',
        'COMMENT FUNCTION st_symdifference(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_symdifference(geometry,geometry)',
        'COMMENT FUNCTION st_touches(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_touches(geometry,geometry)',
        'COMMENT FUNCTION st_transform(geometry,integer)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_transform(rast raster,sridinteger,algorithmtext,maxerrdouble precision,scalexdouble precision,scaleydouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_transform(rast raster,sridinteger,scalexdouble precision,scaleydouble precision,algorithmtext,maxerrdouble precision)',
        'COMMENT FUNCTION st_translate(geometry,double precision,double precision)',
        'COMMENT FUNCTION st_translate(geometry,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_transscale(geometry,double precision,double precision,double precision,double precision)',
        'COMMENT FUNCTION st_unaryunion(geometry)',
        'COMMENT FUNCTION st_union(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_union(geometry[])',
        'COMMENT FUNCTION st_union(geometry,geometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_upperleftx(raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_upperlefty(raster)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rastertabletext,rastercolumntext,nband integer,exclude_nodata_valueboolean,searchvaluedouble precision,roundtodouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rastertabletext,rastercolumntext,nband integer,exclude_nodata_valueboolean,searchvaluesdouble precision[],roundtodouble precision,OUTvaluedouble precision,OUTcountinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rastertabletext,rastercolumntext,nband integer,searchvaluedouble precision,roundtodouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rastertabletext,rastercolumntext,nband integer,searchvaluesdouble precision[],roundtodouble precision,OUTvaluedouble precision,OUTcountinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rastertabletext,rastercolumntext,searchvaluedouble precision,roundtodouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rastertabletext,rastercolumntext,searchvaluesdouble precision[],roundtodouble precision,OUTvaluedouble precision,OUTcountinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rast raster,nband integer,exclude_nodata_valueboolean,searchvaluedouble precision,roundtodouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rast raster,nband integer,exclude_nodata_valueboolean,searchvaluesdouble precision[],roundtodouble precision,OUTvaluedouble precision,OUTcountinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rast raster,nband integer,searchvaluedouble precision,roundtodouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rast raster,nband integer,searchvaluesdouble precision[],roundtodouble precision,OUTvaluedouble precision,OUTcountinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rast raster,searchvaluedouble precision,roundtodouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_valuecount(rast raster,searchvaluesdouble precision[],roundtodouble precision,OUTvaluedouble precision,OUTcountinteger)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_value(rast raster,bandinteger,ptgeometry,hasnodataboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_value(rast raster,bandinteger,xinteger,yinteger,hasnodataboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_value(rast raster,ptgeometry,hasnodataboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_value(rast raster,xinteger,yinteger,hasnodataboolean)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_width(raster)',
        'COMMENT FUNCTION st_within(geom1 geometry,geom2 geometry)',
        'COMMENT FUNCTION st_within(geometry,geometry)',
        'COMMENT FUNCTION st_wkbtosql(bytea)',
        'COMMENT FUNCTION st_wkbtosql(wkb bytea)',
        'COMMENT FUNCTION st_wkttosql(text)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_world2rastercoordx(rast raster,ptgeometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_world2rastercoordx(rast raster,xwdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_world2rastercoordx(rast raster,xwdouble precision,ywdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_world2rastercoordy(rast raster,ptgeometry)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_world2rastercoordy(rast raster,xwdouble precision,ywdouble precision)',
         # PG12_DEPRECATED
         'COMMENT FUNCTION st_world2rastercoordy(rast raster,ywdouble precision)',
        'COMMENT FUNCTION st_x(geometry)',
        'COMMENT FUNCTION st_xmax(box3d)',
        'COMMENT FUNCTION st_xmin(box3d)',
        'COMMENT FUNCTION st_y(geometry)',
        'COMMENT FUNCTION st_ymax(box3d)',
        'COMMENT FUNCTION st_ymin(box3d)',
        'COMMENT FUNCTION st_z(geometry)',
        'COMMENT FUNCTION st_zmax(box3d)',
        'COMMENT FUNCTION st_zmflag(geometry)',
        'COMMENT FUNCTION st_zmin(box3d)',
        'COMMENT FUNCTION topogeo_addlinestring(atopology character varying,aline public.geometry,tolerance double precision)',
        'COMMENT FUNCTION topogeo_addpoint(atopology character varying,apoint public.geometry,tolerance double precision)',
        'COMMENT FUNCTION topogeo_addpolygon(atopology character varying,apoly public.geometry,tolerance double precision)',
        'COMMENT FUNCTION topologysummary(atopologycharacter varying)',
        'COMMENT FUNCTION totopogeom(ageom public.geometry,atopology character varying,alayer integer,atolerance double precision)',
        'COMMENT FUNCTION unlockrows(text)',
        'COMMENT FUNCTION updategeometrysrid(catalogn_namecharacter varying,schema_namecharacter varying,character varying,column_namecharacter varying,new_sridinteger)',
        'COMMENT FUNCTION updategeometrysrid(character varying,character varying,character varying,character varying,integer)',
        'COMMENT FUNCTION updategeometrysrid(character varying,character varying,character varying,integer)',
        'COMMENT FUNCTION updategeometrysrid(character varying,character varying,integer)',
        'COMMENT FUNCTION validatetopology(character varying)',
        'COMMENT FUNCTION validatetopology(character varying)',
        'COMMENT TYPE box2d',
        'COMMENT TYPE box3d',
        'COMMENT TYPE box3d_extent',
        'COMMENT TYPE geography',
        'COMMENT TYPE geometry',
        'COMMENT TYPE geometry_dump',
        'COMMENT TYPE geomval',
        'COMMENT TYPE getfaceedges_returntype',
        'COMMENT TYPE histogram',
         # PG12_DEPRECATED
         'COMMENT TYPE raster',
        'COMMENT TYPE reclassarg',
        'COMMENT TYPE summarystats',
        'COMMENT TYPE topogeometry',
        'COMMENT TYPE validatetopology_returntype',
        'DOMAIN topoelement',
        'DOMAIN topoelementarray',
        'DOMAIN topogeomelementarray',
        'FUNCTION addauth(text)',
        'FUNCTION addbbox(geometry)',
        'FUNCTION addedge(character varying,public.geometry)',
        'FUNCTION addface(character varying,public.geometry,boolean)',
        'FUNCTION addgeometrycolumn(character varying,character varying,character varying,character varying,integer,character varying,integer)',
        'FUNCTION addgeometrycolumn(character varying,character varying,character varying,character varying,integer,character varying,integer,boolean)',
        'FUNCTION addgeometrycolumn(character varying,character varying,character varying,integer,character varying,integer)',
        'FUNCTION addgeometrycolumn(character varying,character varying,character varying,integer,character varying,integer,boolean)',
        'FUNCTION addgeometrycolumn(character varying,character varying,integer,character varying,integer)',
        'FUNCTION addgeometrycolumn(character varying,character varying,integer,character varying,integer,boolean)',
        'FUNCTION addnode(character varying,public.geometry)',
        'FUNCTION addnode(character varying,public.geometry,boolean,boolean)',
        'FUNCTION _add_overview_constraint(name,name,name,name,name,name,integer)',
        'FUNCTION addoverviewconstraints(name,name,name,name,integer)',
        'FUNCTION addoverviewconstraints(name,name,name,name,name,name,integer)',
        'FUNCTION addpoint(geometry,geometry)',
        'FUNCTION addpoint(geometry,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION addrastercolumn(character varying,character varying,character varying,character varying,integer,character varying[],boolean,boolean,double precision[],double precision,double precision,integer,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION addrastercolumn(character varying,character varying,character varying,integer,character varying[],boolean,boolean,double precision[],double precision,double precision,integer,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION addrastercolumn(character varying,character varying,integer,character varying[],boolean,boolean,double precision[],double precision,double precision,integer,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_alignment(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_blocksize(name,name,name,text)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_extent(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint(name,text)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_nodata_values(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_num_bands(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_out_db(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_pixel_types(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_regular_blocking(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_scale(name,name,name,character)',
         # PG12_DEPRECATED
         'FUNCTION addrasterconstraints(name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION addrasterconstraints(name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION addrasterconstraints(name,name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION addrasterconstraints(name,name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION addrasterconstraints(name,name,name,text[])',
         # PG12_DEPRECATED
         'FUNCTION addrasterconstraints(name,name,text[])',
         # PG12_DEPRECATED
         'FUNCTION _add_raster_constraint_srid(name,name,name)',
        'FUNCTION addtopogeometrycolumn(character varying,character varying,character varying,character varying,character varying)',
        'FUNCTION addtopogeometrycolumn(character varying,character varying,character varying,character varying,character varying,integer)',
        'FUNCTION addtosearchpath(character varying)',
        'FUNCTION affine(geometry,double precision,double precision,double precision,double precision,double precision,double precision)',
        'FUNCTION affine(geometry,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision)',
        'FUNCTION area2d(geometry)',
        'FUNCTION area(geometry)',
        'FUNCTION asbinary(geometry)',
        'FUNCTION asbinary(geometry,text)',
        'FUNCTION asewkb(geometry)',
        'FUNCTION asewkb(geometry,text)',
        'FUNCTION asewkt(geometry)',
        'FUNCTION _asgmledge(integer,integer,integer,public.geometry,regclass,text,integer,integer)',
        'FUNCTION _asgmledge(integer,integer,integer,public.geometry,regclass,text,integer,integer,text)',
        'FUNCTION _asgmledge(integer,integer,integer,public.geometry,regclass,text,integer,integer,text,integer)',
        'FUNCTION _asgmledge(integer,integer,integer,public.geometry,text)',
        'FUNCTION asgmledge(integer,integer,integer,public.geometry,text)',
        'FUNCTION _asgmledge(integer,integer,integer,public.geometry,text,integer,integer)',
        'FUNCTION _asgmlface(text,integer,regclass,text,integer,integer,text,integer)',
        'FUNCTION asgml(geometry)',
        'FUNCTION asgml(geometry,integer)',
        'FUNCTION asgml(geometry,integer,integer)',
        'FUNCTION _asgmlnode(integer,public.geometry,text)',
        'FUNCTION asgmlnode(integer,public.geometry,text)',
        'FUNCTION _asgmlnode(integer,public.geometry,text,integer,integer)',
        'FUNCTION _asgmlnode(integer,public.geometry,text,integer,integer,text)',
        'FUNCTION _asgmlnode(integer,public.geometry,text,integer,integer,text,integer)',
        'FUNCTION asgml(topogeometry)',
        'FUNCTION asgml(topogeometry,regclass)',
        'FUNCTION asgml(topogeometry,regclass,text)',
        'FUNCTION asgml(topogeometry,text)',
        'FUNCTION asgml(topogeometry,text,integer,integer)',
        'FUNCTION asgml(topogeometry,text,integer,integer,regclass)',
        'FUNCTION asgml(topogeometry,text,integer,integer,regclass,text)',
        'FUNCTION asgml(topogeometry,text,integer,integer,regclass,text,integer)',
        'FUNCTION ashexewkb(geometry)',
        'FUNCTION ashexewkb(geometry,text)',
        'FUNCTION askml(geometry)',
        'FUNCTION askml(geometry,integer)',
        'FUNCTION askml(geometry,integer,integer)',
        'FUNCTION askml(integer,geometry,integer)',
        'FUNCTION assvg(geometry)',
        'FUNCTION assvg(geometry,integer)',
        'FUNCTION assvg(geometry,integer,integer)',
        'FUNCTION astext(geometry)',
        'FUNCTION asukml(geometry)',
        'FUNCTION asukml(geometry,integer)',
        'FUNCTION asukml(geometry,integer,integer)',
        'FUNCTION azimuth(geometry,geometry)',
        'FUNCTION bdmpolyfromtext(text,integer)',
        'FUNCTION bdpolyfromtext(text,integer)',
        'FUNCTION boundary(geometry)',
        'FUNCTION box2d(box3d)',
        'FUNCTION box2d(box3d_extent)',
        'FUNCTION box2d_contain(box2d,box2d)',
        'FUNCTION box2d_contained(box2d,box2d)',
        'FUNCTION box2df_in(cstring)',
        'FUNCTION box2df_out(box2df)',
        'FUNCTION box2d(geometry)',
        'FUNCTION box2d_in(cstring)',
        'FUNCTION box2d_intersects(box2d,box2d)',
        'FUNCTION box2d_left(box2d,box2d)',
        'FUNCTION box2d_out(box2d)',
        'FUNCTION box2d_overlap(box2d,box2d)',
        'FUNCTION box2d_overleft(box2d,box2d)',
        'FUNCTION box2d_overright(box2d,box2d)',
         # PG12_DEPRECATED
         'FUNCTION box2d(raster)',
        'FUNCTION box2d_right(box2d,box2d)',
        'FUNCTION box2d_same(box2d,box2d)',
        'FUNCTION box3d(box2d)',
        'FUNCTION box3d_extent(box3d_extent)',
        'FUNCTION box3d_extent_in(cstring)',
        'FUNCTION box3d_extent_out(box3d_extent)',
        'FUNCTION box3d(geometry)',
        'FUNCTION box3d_in(cstring)',
        'FUNCTION box3d_out(box3d)',
         # PG12_DEPRECATED
         'FUNCTION box3d(raster)',
        'FUNCTION box3dtobox(box3d)',
        'FUNCTION box(box3d)',
        'FUNCTION box(geometry)',
        'FUNCTION buffer(geometry,double precision)',
        'FUNCTION buffer(geometry,double precision,integer)',
        'FUNCTION buildarea(geometry)',
        'FUNCTION build_histogram2d(histogram2d,text,text)',
        'FUNCTION build_histogram2d(histogram2d,text,text,text)',
        'FUNCTION bytea(geography)',
        'FUNCTION bytea(geometry)',
         # PG12_DEPRECATED
         'FUNCTION bytea(raster)',
        'FUNCTION cache_bbox()',
        'FUNCTION centroid(geometry)',
        'FUNCTION checkauth(text,text)',
        'FUNCTION checkauth(text,text,text)',
        'FUNCTION checkauthtrigger()',
        'FUNCTION chip_in(cstring)',
        'FUNCTION chip_out(chip)',
        'FUNCTION collect_garray(geometry[])',
        'FUNCTION collect(geometry,geometry)',
        'FUNCTION collector(geometry,geometry)',
        'FUNCTION combine_bbox(box2d,geometry)',
        'FUNCTION combine_bbox(box3d_extent,geometry)',
        'FUNCTION combine_bbox(box3d,geometry)',
        'FUNCTION compression(chip)',
        'FUNCTION contains(geometry,geometry)',
        'FUNCTION convexhull(geometry)',
        'FUNCTION copytopology(character varying,character varying)',
        'FUNCTION create_histogram2d(box2d,integer)',
        'FUNCTION createtopogeom(character varying,integer,integer)',
        'FUNCTION createtopogeom(character varying,integer,integer,topoelementarray)',
        'FUNCTION createtopology(character varying)',
        'FUNCTION createtopology(character varying,integer)',
        'FUNCTION createtopology(character varying,integer,double precision)',
        'FUNCTION createtopology(character varying,integer,double precision,boolean)',
        'FUNCTION crosses(geometry,geometry)',
        'FUNCTION datatype(chip)',
        'FUNCTION difference(geometry,geometry)',
        'FUNCTION dimension(geometry)',
        'FUNCTION disablelongtransactions()',
        'FUNCTION disjoint(geometry,geometry)',
        'FUNCTION distance(geometry,geometry)',
        'FUNCTION distance_sphere(geometry,geometry)',
        'FUNCTION distance_spheroid(geometry,geometry,spheroid)',
        'FUNCTION dropbbox(geometry)',
        'FUNCTION dropgeometrycolumn(character varying,character varying)',
        'FUNCTION dropgeometrycolumn(character varying,character varying,character varying)',
        'FUNCTION dropgeometrycolumn(character varying,character varying,character varying,character varying)',
        'FUNCTION dropgeometrytable(character varying)',
        'FUNCTION dropgeometrytable(character varying,character varying)',
        'FUNCTION dropgeometrytable(character varying,character varying,character varying)',
        'FUNCTION _drop_overview_constraint(name,name,name)',
        'FUNCTION dropoverviewconstraints(name,name)',
        'FUNCTION dropoverviewconstraints(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION droprastercolumn(character varying,character varying)',
         # PG12_DEPRECATED
         'FUNCTION droprastercolumn(character varying,character varying,character varying)',
         # PG12_DEPRECATED
         'FUNCTION droprastercolumn(character varying,character varying,character varying,character varying)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_alignment(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_blocksize(name,name,name,text)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_extent(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_nodata_values(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_num_bands(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_out_db(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_pixel_types(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_regular_blocking(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_scale(name,name,name,character)',
         # PG12_DEPRECATED
         'FUNCTION droprasterconstraints(name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION droprasterconstraints(name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION droprasterconstraints(name,name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION droprasterconstraints(name,name,name,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)',
         # PG12_DEPRECATED
         'FUNCTION droprasterconstraints(name,name,name,text[])',
         # PG12_DEPRECATED
         'FUNCTION droprasterconstraints(name,name,text[])',
         # PG12_DEPRECATED
         'FUNCTION _drop_raster_constraint_srid(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION droprastertable(character varying)',
         # PG12_DEPRECATED
         'FUNCTION droprastertable(character varying,character varying)',
         # PG12_DEPRECATED
         'FUNCTION droprastertable(character varying,character varying,character varying)',
        'FUNCTION droptopogeometrycolumn(character varying,character varying,character varying)',
        'FUNCTION droptopology(character varying)',
         # PG12_DEPRECATED
         'FUNCTION dumpaswktpolygons(raster,integer)',
        'FUNCTION dump(geometry)',
        'FUNCTION dumprings(geometry)',
        'FUNCTION enablelongtransactions()',
        'FUNCTION endpoint(geometry)',
        'FUNCTION envelope(geometry)',
        'FUNCTION envelope(topogeometry)',
        'FUNCTION equals(geometry,geometry)',
        'FUNCTION equals(topogeometry,topogeometry)',
        'FUNCTION estimated_extent(text,text)',
        'FUNCTION estimated_extent(text,text,text)',
        'FUNCTION estimate_histogram2d(histogram2d,box2d)',
        'FUNCTION expand(box2d,double precision)',
        'FUNCTION expand(box3d,double precision)',
        'FUNCTION expand(geometry,double precision)',
        'FUNCTION explode_histogram2d(histogram2d,text)',
        'FUNCTION exteriorring(geometry)',
        'FUNCTION factor(chip)',
        'FUNCTION find_extent(text,text)',
        'FUNCTION find_extent(text,text,text)',
        'FUNCTION find_srid(character varying,character varying,character varying)',
        'FUNCTION fix_geometry_columns()',
        'FUNCTION force_2d(geometry)',
        'FUNCTION force_3d(geometry)',
        'FUNCTION force_3dm(geometry)',
        'FUNCTION force_3dz(geometry)',
        'FUNCTION force_4d(geometry)',
        'FUNCTION force_collection(geometry)',
        'FUNCTION forcerhr(geometry)',
        'FUNCTION geography_analyze(internal)',
        'FUNCTION geography(bytea)',
        'FUNCTION geography_cmp(geography,geography)',
        'FUNCTION geography_eq(geography,geography)',
        'FUNCTION geography_ge(geography,geography)',
        'FUNCTION geography(geography,integer,boolean)',
        'FUNCTION geography(geometry)',
        'FUNCTION geography_gist_compress(internal)',
        'FUNCTION geography_gist_consistent(internal,geography,integer)',
        'FUNCTION geography_gist_consistent(internal,geometry,integer)',
        'FUNCTION geography_gist_decompress(internal)',
        'FUNCTION geography_gist_join_selectivity(internal,oid,internal,smallint)',
        'FUNCTION geography_gist_penalty(internal,internal,internal)',
        'FUNCTION geography_gist_picksplit(internal,internal)',
        'FUNCTION geography_gist_same(box2d,box2d,internal)',
        'FUNCTION geography_gist_selectivity(internal,oid,internal,integer)',
        'FUNCTION geography_gist_union(bytea,internal)',
        'FUNCTION geography_gt(geography,geography)',
        'FUNCTION geography_in(cstring,oid,integer)',
        'FUNCTION geography_le(geography,geography)',
        'FUNCTION geography_lt(geography,geography)',
        'FUNCTION geography_out(geography)',
        'FUNCTION geography_overlaps(geography,geography)',
        'FUNCTION geography_recv(internal,oid,integer)',
        'FUNCTION geography_send(geography)',
        'FUNCTION geography_typmod_dims(integer)',
        'FUNCTION geography_typmod_in(cstring[])',
        'FUNCTION geography_typmod_out(integer)',
        'FUNCTION geography_typmod_srid(integer)',
        'FUNCTION geography_typmod_type(integer)',
        'FUNCTION geom_accum(geometry[],geometry)',
        'FUNCTION geomcollfromtext(text)',
        'FUNCTION geomcollfromtext(text,integer)',
        'FUNCTION geomcollfromwkb(bytea)',
        'FUNCTION geomcollfromwkb(bytea,integer)',
        'FUNCTION geometry_above(geometry,geometry)',
        'FUNCTION geometry_analyze(internal)',
        'FUNCTION geometry_below(geometry,geometry)',
        'FUNCTION geometry(box2d)',
        'FUNCTION geometry(box3d)',
        'FUNCTION geometry(box3d_extent)',
        'FUNCTION geometry(bytea)',
        'FUNCTION geometry(chip)',
        'FUNCTION geometry_cmp(geometry,geometry)',
        'FUNCTION geometry_contained(geometry,geometry)',
        'FUNCTION geometry_contain(geometry,geometry)',
        'FUNCTION geometry_contains(geometry,geometry)',
        'FUNCTION geometry_distance_box(geometry,geometry)',
        'FUNCTION geometry_distance_centroid(geometry,geometry)',
        'FUNCTION geometry_eq(geometry,geometry)',
        'FUNCTION geometryfromtext(text)',
        'FUNCTION geometryfromtext(text,integer)',
        'FUNCTION geometry_ge(geometry,geometry)',
        'FUNCTION geometry(geography)',
        'FUNCTION geometry(geometry,integer,boolean)',
        'FUNCTION geometry_gist_compress_2d(internal)',
        'FUNCTION geometry_gist_compress_nd(internal)',
        'FUNCTION geometry_gist_consistent_2d(internal,geometry,integer)',
        'FUNCTION geometry_gist_consistent_nd(internal,geometry,integer)',
        'FUNCTION geometry_gist_decompress_2d(internal)',
        'FUNCTION geometry_gist_decompress_nd(internal)',
        'FUNCTION geometry_gist_distance_2d(internal,geometry,integer)',
        'FUNCTION geometry_gist_joinsel_2d(internal,oid,internal,smallint)',
        'FUNCTION geometry_gist_joinsel(internal,oid,internal,smallint)',
        'FUNCTION geometry_gist_penalty_2d(internal,internal,internal)',
        'FUNCTION geometry_gist_penalty_nd(internal,internal,internal)',
        'FUNCTION geometry_gist_picksplit_2d(internal,internal)',
        'FUNCTION geometry_gist_picksplit_nd(internal,internal)',
        'FUNCTION geometry_gist_same_2d(geometry,geometry,internal)',
        'FUNCTION geometry_gist_same_nd(geometry,geometry,internal)',
        'FUNCTION geometry_gist_sel_2d(internal,oid,internal,integer)',
        'FUNCTION geometry_gist_sel(internal,oid,internal,integer)',
        'FUNCTION geometry_gist_union_2d(bytea,internal)',
        'FUNCTION geometry_gist_union_nd(bytea,internal)',
        'FUNCTION geometry_gt(geometry,geometry)',
        'FUNCTION geometry_in(cstring)',
        'FUNCTION geometry_left(geometry,geometry)',
        'FUNCTION geometry_le(geometry,geometry)',
        'FUNCTION geometry_lt(geometry,geometry)',
        'FUNCTION geometryn(geometry,integer)',
        'FUNCTION geometry_out(geometry)',
        'FUNCTION geometry_overabove(geometry,geometry)',
        'FUNCTION geometry_overbelow(geometry,geometry)',
        'FUNCTION geometry_overlap(geometry,geometry)',
        'FUNCTION geometry_overlaps(geometry,geometry)',
        'FUNCTION geometry_overlaps_nd(geometry,geometry)',
        'FUNCTION geometry_overleft(geometry,geometry)',
        'FUNCTION geometry_overright(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION geometry_raster_contain(geometry,raster)',
         # PG12_DEPRECATED
         'FUNCTION geometry_raster_overlap(geometry,raster)',
        'FUNCTION geometry_recv(internal)',
        'FUNCTION geometry_right(geometry,geometry)',
        'FUNCTION geometry_samebox(geometry,geometry)',
        'FUNCTION geometry_same(geometry,geometry)',
        'FUNCTION geometry_send(geometry)',
        'FUNCTION geometry(text)',
        'FUNCTION geometry(topogeometry)',
        'FUNCTION geometrytype(geography)',
        'FUNCTION geometrytype(geometry)',
        'FUNCTION geometrytype(topogeometry)',
        'FUNCTION geometry_typmod_in(cstring[])',
        'FUNCTION geometry_typmod_out(integer)',
        'FUNCTION geometry_within(geometry,geometry)',
        'FUNCTION geomfromewkb(bytea)',
        'FUNCTION geomfromewkt(text)',
        'FUNCTION geomfromtext(text)',
        'FUNCTION geomfromtext(text,integer)',
        'FUNCTION geomfromwkb(bytea)',
        'FUNCTION geomfromwkb(bytea,integer)',
        'FUNCTION geomunion(geometry,geometry)',
        'FUNCTION geosnoop(geometry)',
        'FUNCTION getbbox(geometry)',
        'FUNCTION getedgebypoint(character varying,public.geometry,double precision)',
        'FUNCTION getfacebypoint(character varying,public.geometry,double precision)',
        'FUNCTION getnodebypoint(character varying,public.geometry,double precision)',
        'FUNCTION get_proj4_from_srid(integer)',
        'FUNCTION getringedges(character varying,integer,integer)',
        'FUNCTION getsrid(geometry)',
        'FUNCTION gettopogeomelementarray(character varying,integer,integer)',
        'FUNCTION gettopogeomelementarray(topogeometry)',
        'FUNCTION gettopogeomelements(character varying,integer,integer)',
        'FUNCTION gettopogeomelements(topogeometry)',
        'FUNCTION gettopologyid(character varying)',
        'FUNCTION gettopologyname(integer)',
        'FUNCTION gettransactionid()',
        'FUNCTION gidx_in(cstring)',
        'FUNCTION gidx_out(gidx)',
        'FUNCTION hasbbox(geometry)',
        'FUNCTION height(chip)',
        'FUNCTION histogram2d_in(cstring)',
        'FUNCTION histogram2d_out(histogram2d)',
        'FUNCTION interiorringn(geometry,integer)',
        'FUNCTION intersection(geometry,geometry)',
        'FUNCTION intersects(geometry,geometry)',
        'FUNCTION intersects(topogeometry,topogeometry)',
        'FUNCTION isclosed(geometry)',
        'FUNCTION isempty(geometry)',
        'FUNCTION isring(geometry)',
        'FUNCTION issimple(geometry)',
        'FUNCTION isvalid(geometry)',
        'FUNCTION jtsnoop(geometry)',
        'FUNCTION layertrigger()',
        'FUNCTION length2d(geometry)',
        'FUNCTION length2d_spheroid(geometry,spheroid)',
        'FUNCTION length3d(geometry)',
        'FUNCTION length3d_spheroid(geometry,spheroid)',
        'FUNCTION length(geometry)',
        'FUNCTION length_spheroid(geometry,spheroid)',
        'FUNCTION linefrommultipoint(geometry)',
        'FUNCTION linefromtext(text)',
        'FUNCTION linefromtext(text,integer)',
        'FUNCTION linefromwkb(bytea)',
        'FUNCTION linefromwkb(bytea,integer)',
        'FUNCTION line_interpolate_point(geometry,double precision)',
        'FUNCTION line_locate_point(geometry,geometry)',
        'FUNCTION linemerge(geometry)',
        'FUNCTION linestringfromtext(text)',
        'FUNCTION linestringfromtext(text,integer)',
        'FUNCTION linestringfromwkb(bytea)',
        'FUNCTION linestringfromwkb(bytea,integer)',
        'FUNCTION line_substring(geometry,double precision,double precision)',
        'FUNCTION locate_along_measure(geometry,double precision)',
        'FUNCTION locate_between_measures(geometry,double precision,double precision)',
        'FUNCTION lockrow(text,text,text)',
        'FUNCTION lockrow(text,text,text,text)',
        'FUNCTION lockrow(text,text,text,text,timestamp without time zone)',
        'FUNCTION lockrow(text,text,text,timestamp without time zone)',
        'FUNCTION longtransactionsenabled()',
        'FUNCTION lwgeom_gist_compress(internal)',
        'FUNCTION lwgeom_gist_consistent(internal,geometry,integer)',
        'FUNCTION lwgeom_gist_decompress(internal)',
        'FUNCTION lwgeom_gist_penalty(internal,internal,internal)',
        'FUNCTION lwgeom_gist_picksplit(internal,internal)',
        'FUNCTION lwgeom_gist_same(box2d,box2d,internal)',
        'FUNCTION lwgeom_gist_union(bytea,internal)',
        'FUNCTION makebox2d(geometry,geometry)',
        'FUNCTION makebox3d(geometry,geometry)',
        'FUNCTION makeline_garray(geometry[])',
        'FUNCTION makeline(geometry,geometry)',
        'FUNCTION makepoint(double precision,double precision)',
        'FUNCTION makepoint(double precision,double precision,double precision)',
        'FUNCTION makepoint(double precision,double precision,double precision,double precision)',
        'FUNCTION makepointm(double precision,double precision,double precision)',
        'FUNCTION makepolygon(geometry)',
        'FUNCTION makepolygon(geometry,geometry[])',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionfinal1(rastexpr)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionfinal3(rastexpr)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(raster,raster,text,text,text,double precision,text,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(rastexpr,raster)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(rastexpr,raster,text)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(rastexpr,raster,text,text)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(rastexpr,raster,text,text,text)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(rastexpr,raster,text,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(rastexpr,raster,text,text,text,double precision,text,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION mapalgebra4unionstate(rastexpr,raster,text,text,text,double precision,text,text,text,double precision,text,text,text,double precision)',
        'FUNCTION max_distance(geometry,geometry)',
        'FUNCTION mem_size(geometry)',
        'FUNCTION m(geometry)',
        'FUNCTION mlinefromtext(text)',
        'FUNCTION mlinefromtext(text,integer)',
        'FUNCTION mlinefromwkb(bytea)',
        'FUNCTION mlinefromwkb(bytea,integer)',
        'FUNCTION mpointfromtext(text)',
        'FUNCTION mpointfromtext(text,integer)',
        'FUNCTION mpointfromwkb(bytea)',
        'FUNCTION mpointfromwkb(bytea,integer)',
        'FUNCTION mpolyfromtext(text)',
        'FUNCTION mpolyfromtext(text,integer)',
        'FUNCTION mpolyfromwkb(bytea)',
        'FUNCTION mpolyfromwkb(bytea,integer)',
        'FUNCTION multi(geometry)',
        'FUNCTION multilinefromwkb(bytea)',
        'FUNCTION multilinefromwkb(bytea,integer)',
        'FUNCTION multilinestringfromtext(text)',
        'FUNCTION multilinestringfromtext(text,integer)',
        'FUNCTION multipointfromtext(text)',
        'FUNCTION multipointfromtext(text,integer)',
        'FUNCTION multipointfromwkb(bytea)',
        'FUNCTION multipointfromwkb(bytea,integer)',
        'FUNCTION multipolyfromwkb(bytea)',
        'FUNCTION multipolyfromwkb(bytea,integer)',
        'FUNCTION multipolygonfromtext(text)',
        'FUNCTION multipolygonfromtext(text,integer)',
        'FUNCTION ndims(geometry)',
        'FUNCTION noop(geometry)',
        'FUNCTION npoints(geometry)',
        'FUNCTION nrings(geometry)',
        'FUNCTION numgeometries(geometry)',
        'FUNCTION numinteriorring(geometry)',
        'FUNCTION numinteriorrings(geometry)',
        'FUNCTION numpoints(geometry)',
        'FUNCTION overlaps(geometry,geometry)',
        'FUNCTION _overview_constraint_info(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _overview_constraint(raster,integer,name,name,name)',
        'FUNCTION perimeter2d(geometry)',
        'FUNCTION perimeter3d(geometry)',
        'FUNCTION perimeter(geometry)',
        'FUNCTION pgis_abs_in(cstring)',
        'FUNCTION pgis_abs_out(pgis_abs)',
        'FUNCTION pgis_geometry_accum_finalfn(pgis_abs)',
        'FUNCTION pgis_geometry_accum_finalfn(internal)',
        'FUNCTION pgis_geometry_accum_transfn(pgis_abs,geometry)',
        'FUNCTION pgis_geometry_accum_transfn(pgis_abs,geometry,double precision)',
        'FUNCTION pgis_geometry_accum_transfn(pgis_abs,geometry,double precision,integer)',
        'FUNCTION pgis_geometry_clusterintersecting_finalfn(pgis_abs)',
        'FUNCTION pgis_geometry_clusterwithin_finalfn(pgis_abs)',
        'FUNCTION pgis_geometry_collect_finalfn(pgis_abs)',
        'FUNCTION pgis_geometry_makeline_finalfn(pgis_abs)',
        'FUNCTION pgis_geometry_polygonize_finalfn(pgis_abs)',
        'FUNCTION pgis_geometry_union_finalfn(pgis_abs)',
        'FUNCTION pointfromtext(text)',
        'FUNCTION pointfromtext(text,integer)',
        'FUNCTION pointfromwkb(bytea)',
        'FUNCTION pointfromwkb(bytea,integer)',
        'FUNCTION point_inside_circle(geometry,double precision,double precision,double precision)',
        'FUNCTION pointn(geometry,integer)',
        'FUNCTION pointonsurface(geometry)',
        'FUNCTION polyfromtext(text)',
        'FUNCTION polyfromtext(text,integer)',
        'FUNCTION polyfromwkb(bytea)',
        'FUNCTION polyfromwkb(bytea,integer)',
        'FUNCTION polygonfromtext(text)',
        'FUNCTION polygonfromtext(text,integer)',
        'FUNCTION polygonfromwkb(bytea)',
        'FUNCTION polygonfromwkb(bytea,integer)',
        'FUNCTION polygonize(character varying)',
        'FUNCTION polygonize_garray(geometry[])',
        'FUNCTION populate_geometry_columns()',
        'FUNCTION populate_geometry_columns(boolean)',
        'FUNCTION populate_geometry_columns(oid)',
        'FUNCTION populate_geometry_columns(oid,boolean)',
        'FUNCTION postgis_addbbox(geometry)',
        'FUNCTION postgis_cache_bbox()',
        'FUNCTION postgis_constraint_dims(text,text,text)',
        'FUNCTION postgis_constraint_srid(text,text,text)',
        'FUNCTION postgis_constraint_type(text,text,text)',
        'FUNCTION postgis_dropbbox(geometry)',
        'FUNCTION postgis_full_version()',
        'FUNCTION postgis_gdal_version()',
        'FUNCTION postgis_geos_version()',
        'FUNCTION postgis_getbbox(geometry)',
        'FUNCTION postgis_gist_joinsel(internal,oid,internal,smallint)',
        'FUNCTION postgis_gist_sel(internal,oid,internal,integer)',
        'FUNCTION postgis_hasbbox(geometry)',
        'FUNCTION postgis_jts_version()',
        'FUNCTION postgis_lib_build_date()',
        'FUNCTION postgis_libjson_version()',
        'FUNCTION postgis_lib_version()',
        'FUNCTION postgis_libxml_version()',
        'FUNCTION postgis_noop(geometry)',
        'FUNCTION postgis_proj_version()',
         # PG12_DEPRECATED
         'FUNCTION postgis_raster_lib_build_date()',
         # PG12_DEPRECATED
         'FUNCTION postgis_raster_lib_version()',
         # PG12_DEPRECATED
         'FUNCTION postgis_raster_scripts_installed()',
        'FUNCTION postgis_scripts_build_date()',
        'FUNCTION postgis_scripts_installed()',
        'FUNCTION postgis_scripts_released()',
        'FUNCTION postgis_topology_scripts_installed()',
        'FUNCTION postgis_transform_geometry(geometry,text,text,integer)',
        'FUNCTION postgis_type_name(character varying,integer,boolean)',
        'FUNCTION postgis_typmod_dims(integer)',
        'FUNCTION postgis_typmod_srid(integer)',
        'FUNCTION postgis_typmod_type(integer)',
        'FUNCTION postgis_uses_stats()',
        'FUNCTION postgis_version()',
        'FUNCTION probe_geometry_columns()',
         # PG12_DEPRECATED
         'FUNCTION raster_above(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_below(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_alignment(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_blocksize(name,name,name,text)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_extent(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_nodata_values(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_num_bands(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_out_db(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_pixel_types(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_regular_blocking(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_scale(name,name,name,character)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_info_srid(name,name,name)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_nodata_values(raster)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_out_db(raster)',
         # PG12_DEPRECATED
         'FUNCTION _raster_constraint_pixel_types(raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_contained(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_contain(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_geometry_contain(raster,geometry)',
         # PG12_DEPRECATED
         'FUNCTION raster_geometry_overlap(raster,geometry)',
         # PG12_DEPRECATED
         'FUNCTION raster_in(cstring)',
         # PG12_DEPRECATED
         'FUNCTION raster_left(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_out(raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_overabove(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_overbelow(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_overlap(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_overleft(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_overright(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_right(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION raster_same(raster,raster)',
        'FUNCTION relate(geometry,geometry)',
        'FUNCTION relate(geometry,geometry,text)',
        'FUNCTION relationtrigger()',
        'FUNCTION removepoint(geometry,integer)',
        'FUNCTION rename_geometry_table_constraints()',
         # PG12_DEPRECATED
         'FUNCTION _rename_raster_tables()',
        'FUNCTION reverse(geometry)',
        'FUNCTION rotate(geometry,double precision)',
        'FUNCTION rotatex(geometry,double precision)',
        'FUNCTION rotatey(geometry,double precision)',
        'FUNCTION rotatez(geometry,double precision)',
        'FUNCTION scale(geometry,double precision,double precision)',
        'FUNCTION scale(geometry,double precision,double precision,double precision)',
        'FUNCTION se_envelopesintersect(geometry,geometry)',
        'FUNCTION segmentize(geometry,double precision)',
        'FUNCTION se_is3d(geometry)',
        'FUNCTION se_ismeasured(geometry)',
        'FUNCTION se_locatealong(geometry,double precision)',
        'FUNCTION se_locatebetween(geometry,double precision,double precision)',
        'FUNCTION se_m(geometry)',
        'FUNCTION setfactor(chip,real)',
        'FUNCTION setpoint(geometry,integer,geometry)',
        'FUNCTION setsrid(chip,integer)',
        'FUNCTION setsrid(geometry,integer)',
        'FUNCTION se_z(geometry)',
        'FUNCTION shift_longitude(geometry)',
        'FUNCTION simplify(geometry,double precision)',
        'FUNCTION snaptogrid(geometry,double precision)',
        'FUNCTION snaptogrid(geometry,double precision,double precision)',
        'FUNCTION snaptogrid(geometry,double precision,double precision,double precision,double precision)',
        'FUNCTION snaptogrid(geometry,geometry,double precision,double precision,double precision,double precision)',
        'FUNCTION spheroid_in(cstring)',
        'FUNCTION spheroid_out(spheroid)',
        'FUNCTION srid(chip)',
        'FUNCTION srid(geometry)',
        'FUNCTION st_3dclosestpoint(geometry,geometry)',
        'FUNCTION _st_3ddfullywithin(geometry,geometry,double precision)',
        'FUNCTION st_3ddfullywithin(geometry,geometry,double precision)',
        'FUNCTION st_3ddistance(geometry,geometry)',
        'FUNCTION _st_3ddwithin(geometry,geometry,double precision)',
        'FUNCTION st_3ddwithin(geometry,geometry,double precision)',
        'FUNCTION st_3dintersects(geometry,geometry)',
        'FUNCTION st_3dlength(geometry)',
        'FUNCTION st_3dlength_spheroid(geometry,spheroid)',
        'FUNCTION st_3dlongestline(geometry,geometry)',
        'FUNCTION st_3dmakebox(geometry,geometry)',
        'FUNCTION ST_3DMakeBox(geometry,geometry)',
        'FUNCTION st_3dmaxdistance(geometry,geometry)',
        'FUNCTION st_3dperimeter(geometry)',
        'FUNCTION ST_3DPerimeter(geometry)',
        'FUNCTION st_3dshortestline(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_above(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,integer,text)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,integer,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,integer,text,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,raster[],integer)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,text)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_addband(raster,text,double precision,double precision)',
        'FUNCTION st_addbbox(geometry)',
        'FUNCTION st_addedgemodface(character varying,integer,integer,public.geometry)',
        'FUNCTION st_addedgenewfaces(character varying,integer,integer,public.geometry)',
        'FUNCTION st_addisoedge(character varying,integer,integer,public.geometry)',
        'FUNCTION st_addisonode(character varying,integer,public.geometry)',
        'FUNCTION st_addmeasure(geometry,double precision,double precision)',
        'FUNCTION st_addpoint(geometry,geometry)',
        'FUNCTION st_addpoint(geometry,geometry,integer)',
        'FUNCTION st_affine(geometry,double precision,double precision,double precision,double precision,double precision,double precision)',
        'FUNCTION st_affine(geometry,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxcount(raster,boolean,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxcount(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxcount(raster,integer,boolean,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxcount(raster,integer,double precision)',
        'FUNCTION st_approxcount(text,text,boolean,double precision)',
        'FUNCTION st_approxcount(text,text,double precision)',
        'FUNCTION st_approxcount(text,text,integer,boolean,double precision)',
        'FUNCTION st_approxcount(text,text,integer,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxhistogram(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxhistogram(raster,integer,boolean,double precision,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_approxhistogram(raster,integer,boolean,double precision,integer,double precision[],boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_approxhistogram(raster,integer,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxhistogram(raster,integer,double precision,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_approxhistogram(raster,integer,double precision,integer,double precision[],boolean)',
        'FUNCTION st_approxhistogram(text,text,double precision)',
        'FUNCTION st_approxhistogram(text,text,integer,boolean,double precision,integer,boolean)',
        'FUNCTION st_approxhistogram(text,text,integer,boolean,double precision,integer,double precision[],boolean)',
        'FUNCTION st_approxhistogram(text,text,integer,double precision)',
        'FUNCTION st_approxhistogram(text,text,integer,double precision,integer,boolean)',
        'FUNCTION st_approxhistogram(text,text,integer,double precision,integer,double precision[],boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,boolean,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,double precision,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,integer,boolean,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,integer,boolean,double precision,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,integer,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxquantile(raster,integer,double precision,double precision[])',
        'FUNCTION st_approxquantile(text,text,boolean,double precision)',
        'FUNCTION st_approxquantile(text,text,double precision)',
        'FUNCTION st_approxquantile(text,text,double precision[])',
        'FUNCTION st_approxquantile(text,text,double precision,double precision)',
        'FUNCTION st_approxquantile(text,text,double precision,double precision[])',
        'FUNCTION st_approxquantile(text,text,integer,boolean,double precision,double precision)',
        'FUNCTION st_approxquantile(text,text,integer,boolean,double precision,double precision[])',
        'FUNCTION st_approxquantile(text,text,integer,double precision,double precision)',
        'FUNCTION st_approxquantile(text,text,integer,double precision,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_approxsummarystats(raster,boolean,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxsummarystats(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxsummarystats(raster,integer,boolean,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_approxsummarystats(raster,integer,double precision)',
        'FUNCTION st_approxsummarystats(text,text,boolean)',
        'FUNCTION st_approxsummarystats(text,text,double precision)',
        'FUNCTION st_approxsummarystats(text,text,integer,boolean,double precision)',
        'FUNCTION st_approxsummarystats(text,text,integer,double precision)',
        'FUNCTION st_area2d(geometry)',
        'FUNCTION st_area(geography)',
        'FUNCTION st_area(geography,boolean)',
        'FUNCTION st_area(geometry)',
        'FUNCTION st_area(text)',
        'FUNCTION startpoint(geometry)',
        'FUNCTION st_asbinary(geography)',
        'FUNCTION st_asbinary(geography,text)',
        'FUNCTION st_asbinary(geometry)',
        'FUNCTION st_asbinary(geometry,text)',
         # PG12_DEPRECATED
         'FUNCTION st_asbinary(raster)',
        'FUNCTION st_asbinary(text)',
        'FUNCTION st_asencodedpolyline(geometry)',
        'FUNCTION st_asencodedpolyline(geometry,integer)',
        'FUNCTION st_asewkb(geometry)',
        'FUNCTION st_asewkb(geometry,text)',
        'FUNCTION st_asewkt(geography)',
        'FUNCTION st_asewkt(geometry)',
        'FUNCTION st_asewkt(text)',
         # PG12_DEPRECATED
         'FUNCTION st_asgdalraster(raster,text,text[],integer)',
        'FUNCTION st_asgeojson(geography)',
        'FUNCTION st_asgeojson(geography,integer)',
        'FUNCTION st_asgeojson(geography,integer,integer)',
        'FUNCTION _st_asgeojson(geography,integer,integer)',
        'FUNCTION st_asgeojson(geometry)',
        'FUNCTION st_asgeojson(geometry,integer)',
        'FUNCTION st_asgeojson(geometry,integer,integer)',
        'FUNCTION _st_asgeojson(geometry,integer,integer)',
        'FUNCTION st_asgeojson(integer,geography)',
        'FUNCTION st_asgeojson(integer,geography,integer)',
        'FUNCTION _st_asgeojson(integer,geography,integer,integer)',
        'FUNCTION st_asgeojson(integer,geography,integer,integer)',
        'FUNCTION st_asgeojson(integer,geometry)',
        'FUNCTION st_asgeojson(integer,geometry,integer)',
        'FUNCTION _st_asgeojson(integer,geometry,integer,integer)',
        'FUNCTION st_asgeojson(integer,geometry,integer,integer)',
        'FUNCTION st_asgeojson(text)',
        'FUNCTION _st_asgeojson(text)',
        'FUNCTION st_asgml(geography)',
        'FUNCTION st_asgml(geography,integer)',
        'FUNCTION st_asgml(geography,integer,integer)',
        'FUNCTION st_asgml(geometry)',
        'FUNCTION st_asgml(geometry,integer)',
        'FUNCTION st_asgml(geometry,integer,integer)',
        'FUNCTION st_asgml(integer,geography)',
        'FUNCTION st_asgml(integer,geography,integer)',
        'FUNCTION _st_asgml(integer,geography,integer,integer)',
        'FUNCTION st_asgml(integer,geography,integer,integer)',
        'FUNCTION _st_asgml(integer,geography,integer,integer,text)',
        'FUNCTION st_asgml(integer,geography,integer,integer,text)',
        'FUNCTION st_asgml(integer,geometry)',
        'FUNCTION _st_asgml(integer,geometry,integer)',
        'FUNCTION st_asgml(integer,geometry,integer)',
        'FUNCTION _st_asgml(integer,geometry,integer,integer)',
        'FUNCTION st_asgml(integer,geometry,integer,integer)',
        'FUNCTION _st_asgml(integer,geometry,integer,integer,text)',
        'FUNCTION st_asgml(integer,geometry,integer,integer,text)',
        'FUNCTION st_asgml(integer,geography,integer,integer,text,text)',
        'FUNCTION _st_asgml(integer,geography,integer,integer,text,text)',
        'FUNCTION st_asgml(text)',
        'FUNCTION st_ashexewkb(geometry)',
        'FUNCTION st_ashexewkb(geometry,text)',
         # PG12_DEPRECATED
         'FUNCTION st_asjpeg(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_asjpeg(raster,integer[],integer)',
         # PG12_DEPRECATED
         'FUNCTION st_asjpeg(raster,integer,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_asjpeg(raster,integer[],text[])',
         # PG12_DEPRECATED
         'FUNCTION st_asjpeg(raster,text[])',
        'FUNCTION st_askml(geography)',
        'FUNCTION st_askml(geography,integer)',
        'FUNCTION st_askml(geometry)',
        'FUNCTION st_askml(geometry,integer)',
        'FUNCTION st_askml(integer,geography)',
        'FUNCTION _st_askml(integer,geography,integer)',
        'FUNCTION st_askml(integer,geography,integer)',
        'FUNCTION _st_askml(integer,geography,integer,text)',
        'FUNCTION st_askml(integer,geography,integer,text)',
        'FUNCTION st_askml(integer,geometry)',
        'FUNCTION _st_askml(integer,geometry,integer)',
        'FUNCTION st_askml(integer,geometry,integer)',
        'FUNCTION _st_askml(integer,geometry,integer,text)',
        'FUNCTION st_askml(integer,geometry,integer,text)',
        'FUNCTION st_askml(text)',
        'FUNCTION st_aslatlontext(geometry)',
        'FUNCTION st_aslatlontext(geometry,text)',
        'FUNCTION _st_aspect4ma(double precision[],text,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_aspect(raster,integer,text)',
         # PG12_DEPRECATED
         'FUNCTION st_aspect(raster,integer,text,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_aspect(raster,integer,text,text,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_aspng(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_aspng(raster,integer[],integer)',
         # PG12_DEPRECATED
         'FUNCTION st_aspng(raster,integer,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_aspng(raster,integer[],text[])',
         # PG12_DEPRECATED
         'FUNCTION st_aspng(raster,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,double precision,double precision,double precision,double precision,text,double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,double precision,double precision,double precision,double precision,text[],double precision[],double precision[],double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION _st_asraster(geometry,double precision,double precision,integer,integer,text[],double precision[],double precision[],double precision,double precision,double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION _st_asraster(geometry,double precision,double precision,integer,integer,text[],double precision[],double precision[],double precision,double precision,double precision,double precision,double precision,double precision,touched boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,double precision,double precision,text,double precision,double precision,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,double precision,double precision,text,double precision,double precision,double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,double precision,double precision,text[],double precision[],double precision[],double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,double precision,double precision,text,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,double precision,double precision,text[],double precision[],double precision[],double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,double precision,double precision,text,double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,double precision,double precision,text[],double precision[],double precision[],double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,text,double precision,double precision,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,text[],double precision[],double precision[],double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,text,double precision,double precision,double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,integer,integer,text[],double precision[],double precision[],double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,raster,text,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,raster,text,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_asraster(geometry,raster,text[],double precision[],double precision[],boolean)',
        'FUNCTION st_assvg(geography)',
        'FUNCTION st_assvg(geography,integer)',
        'FUNCTION st_assvg(geography,integer,integer)',
        'FUNCTION st_assvg(geometry)',
        'FUNCTION st_assvg(geometry,integer)',
        'FUNCTION st_assvg(geometry,integer,integer)',
        'FUNCTION st_assvg(text)',
        'FUNCTION st_astext(geography)',
        'FUNCTION st_astext(geometry)',
        'FUNCTION st_astext(text)',
         # PG12_DEPRECATED
         'FUNCTION st_astiff(raster,integer[],text,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_astiff(raster,integer[],text[],integer)',
         # PG12_DEPRECATED
         'FUNCTION st_astiff(raster,text,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_astiff(raster,text[],integer)',
        'FUNCTION st_astwkb(geometry,integer)',
        'FUNCTION st_astwkb(geometry,integer,bigint)',
        'FUNCTION st_astwkb(geometry,integer,bigint,boolean)',
        'FUNCTION st_asukml(geometry)',
        'FUNCTION st_asukml(geometry,integer)',
        'FUNCTION st_asukml(geometry,integer,integer)',
        'FUNCTION st_asx3d(geometry)',
        'FUNCTION st_asx3d(geometry,integer)',
        'FUNCTION st_asx3d(geometry,integer,integer)',
        'FUNCTION _st_asx3d(integer,geometry,integer,integer,text)',
        'FUNCTION st_azimuth(geography,geography)',
        'FUNCTION st_azimuth(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_bandisnodata(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_bandisnodata(raster,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_bandisnodata(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_bandisnodata(raster,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_bandmetadata(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_bandmetadata(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_bandmetadata(raster,integer[])',
         # PG12_DEPRECATED
         'FUNCTION st_bandmetadata(raster,variadic integer[])',
         # PG12_DEPRECATED
         'FUNCTION st_bandnodatavalue(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_bandnodatavalue(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_bandpath(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_bandpath(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_bandpixeltype(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_bandpixeltype(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_band(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_band(raster,integer[])',
         # PG12_DEPRECATED
         'FUNCTION st_band(raster,text,character)',
         # PG12_DEPRECATED
         'FUNCTION st_bandsurface(raster,integer)',
        'FUNCTION st_bdmpolyfromtext(text,integer)',
        'FUNCTION st_bdpolyfromtext(text,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_below(raster,raster)',
        'FUNCTION _st_bestsrid(geography)',
        'FUNCTION _st_bestsrid(geography,geography)',
        'FUNCTION st_boundary(geometry)',
        'FUNCTION st_box2d(box3d)',
        'FUNCTION st_box2d(box3d_extent)',
        'FUNCTION st_box2d_contain(box2d,box2d)',
        'FUNCTION st_box2d_contained(box2d,box2d)',
        'FUNCTION st_box2d(geometry)',
        'FUNCTION st_box2d_in(cstring)',
        'FUNCTION st_box2d_intersects(box2d,box2d)',
        'FUNCTION st_box2d_left(box2d,box2d)',
        'FUNCTION st_box2d_out(box2d)',
        'FUNCTION st_box2d_overlap(box2d,box2d)',
        'FUNCTION st_box2d_overleft(box2d,box2d)',
        'FUNCTION st_box2d_overright(box2d,box2d)',
        'FUNCTION st_box2d_right(box2d,box2d)',
        'FUNCTION st_box2d_same(box2d,box2d)',
        'FUNCTION st_box3d(box2d)',
        'FUNCTION st_box3d_extent(box3d_extent)',
        'FUNCTION st_box3d(geometry)',
        'FUNCTION st_box3d_in(cstring)',
        'FUNCTION st_box3d_out(box3d)',
        'FUNCTION st_box(box3d)',
        'FUNCTION st_box(geometry)',
        'FUNCTION st_buffer(geography,double precision)',
        'FUNCTION st_buffer(geometry,double precision)',
        'FUNCTION _st_buffer(geometry,double precision,cstring)',
        'FUNCTION st_buffer(geometry,double precision,integer)',
        'FUNCTION st_buffer(geometry,double precision,text)',
        'FUNCTION st_buffer(text,double precision)',
        'FUNCTION st_buildarea(geometry)',
        'FUNCTION st_build_histogram2d(histogram2d,text,text)',
        'FUNCTION st_build_histogram2d(histogram2d,text,text,text)',
        'FUNCTION st_bytea(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_bytea(raster)',
        'FUNCTION st_cache_bbox()',
        'FUNCTION st_centroid(geometry)',
        'FUNCTION _st_changeedgegeom_adjacent_edges(character varying,integer,integer)',
        'FUNCTION st_changeedgegeom(character varying,integer,public.geometry)',
        'FUNCTION st_chip_in(cstring)',
        'FUNCTION st_chip_out(chip)',
        'FUNCTION st_cleangeometry(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_clip(raster,geometry,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_clip(raster,geometry,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_clip(raster,geometry,double precision[],boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_clip(raster,integer,geometry,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_clip(raster,integer,geometry,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_clip(raster,integer,geometry,double precision[],boolean)',
        'FUNCTION st_closestpoint(geometry,geometry)',
        'FUNCTION st_collect_garray(geometry[])',
        'FUNCTION st_collect(geometry[])',
        'FUNCTION st_collect(geometry,geometry)',
        'FUNCTION st_collectionextract(geometry,integer)',
        'FUNCTION st_collectionhomogenize(geometry)',
        'FUNCTION st_collector(geometry,geometry)',
        'FUNCTION st_combine_bbox(box2d,geometry)',
        'FUNCTION st_combine_bbox(box3d_extent,geometry)',
        'FUNCTION st_combine_bbox(box3d,geometry)',
        'FUNCTION st_compression(chip)',
        'FUNCTION _st_concavehull(geometry)',
        'FUNCTION st_concavehull(geometry,double precision,boolean)',
        'FUNCTION st_concavehull(geometry,float)',
        'FUNCTION _st_concvehull(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_contained(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_contain(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_contain(raster,raster)**/',
        'FUNCTION _st_contains(geometry,geometry)',
        'FUNCTION st_contains(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION _st_contains(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_contains(geometry,raster,integer)',
        'FUNCTION _st_containsproperly(geometry,geometry)',
        'FUNCTION st_containsproperly(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION _st_contains(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_contains(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_contains(raster,integer,geometry)',
        'FUNCTION st_convexhull(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_convexhull(raster)',
        'FUNCTION st_coorddim(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_count(raster,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_count(raster,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION _st_count(raster,integer,boolean,double precision)',
        'FUNCTION st_count(text,text,boolean)',
        'FUNCTION st_count(text,text,integer,boolean)',
        'FUNCTION _st_count(text,text,integer,boolean,double precision)',
        'FUNCTION st_coveredby(geography,geography)',
        'FUNCTION _st_coveredby(geometry,geometry)',
        'FUNCTION st_coveredby(geometry,geometry)',
        'FUNCTION st_coveredby(text,text)',
        'FUNCTION _st_covers(geography,geography)',
        'FUNCTION st_covers(geography,geography)',
        'FUNCTION _st_covers(geometry,geometry)',
        'FUNCTION st_covers(geometry,geometry)',
        'FUNCTION st_covers(text,text)',
        'FUNCTION st_create_histogram2d(box2d,integer)',
        'FUNCTION st_createtopogeo(character varying,public.geometry)',
        'FUNCTION _st_crosses(geometry,geometry)',
        'FUNCTION st_crosses(geometry,geometry)',
        'FUNCTION st_curvetoline(geometry)',
        'FUNCTION st_curvetoline(geometry,integer)',
        'FUNCTION st_datatype(chip)',
        'FUNCTION _st_dfullywithin(geometry,geometry,double precision)',
        'FUNCTION st_dfullywithin(geometry,geometry,double precision)',
        'FUNCTION st_difference(geometry,geometry)',
        'FUNCTION st_dimension(geometry)',
        'FUNCTION st_disjoint(geometry,geometry)',
        'FUNCTION st_distance(geography,geography)',
        'FUNCTION st_distance(geography,geography,boolean)',
        'FUNCTION _st_distance(geography,geography,double precision,boolean)',
        'FUNCTION st_distance(geometry,geometry)',
        'FUNCTION st_distance_sphere(geometry,geometry)',
        'FUNCTION st_distance_spheroid(geometry,geometry,spheroid)',
        'FUNCTION st_distance(text,text)',
        'FUNCTION st_dropbbox(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_dumpaspolygons(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_dumpaspolygons(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION _st_dumpaswktpolygons(raster,integer)',
        'FUNCTION st_dump(geometry)',
        'FUNCTION st_dumppoints(geometry)',
        'FUNCTION _st_dumppoints(geometry,integer[])',
        'FUNCTION st_dumprings(geometry)',
        'FUNCTION st_dwithin(geography,geography,double precision)',
        'FUNCTION _st_dwithin(geography,geography,double precision,boolean)',
        'FUNCTION st_dwithin(geography,geography,double precision,boolean)',
        'FUNCTION _st_dwithin(geometry,geometry,double precision)',
        'FUNCTION st_dwithin(geometry,geometry,double precision)',
        'FUNCTION st_dwithin(text,text,double precision)',
        'FUNCTION st_endpoint(geometry)',
        'FUNCTION st_envelope(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_envelope(raster)',
        'FUNCTION _st_equals(geometry,geometry)',
        'FUNCTION st_equals(geometry,geometry)',
        'FUNCTION st_estimated_extent(text,text)',
        'FUNCTION st_estimated_extent(text,text,text)',
        'FUNCTION st_estimate_histogram2d(histogram2d,box2d)',
        'FUNCTION st_expand(box2d,double precision)',
        'FUNCTION st_expand(box3d,double precision)',
        'FUNCTION _st_expand(geography,double precision)',
        'FUNCTION st_expand(geometry,double precision)',
        'FUNCTION st_explode_histogram2d(histogram2d,text)',
        'FUNCTION st_exteriorring(geometry)',
        'FUNCTION st_factor(chip)',
        'FUNCTION st_find_extent(text,text)',
        'FUNCTION st_find_extent(text,text,text)',
        'FUNCTION st_flipcoordinates(geometry)',
        'FUNCTION st_force_2d(geometry)',
        'FUNCTION st_force_3d(geometry)',
        'FUNCTION st_force_3dm(geometry)',
        'FUNCTION st_force_3dz(geometry)',
        'FUNCTION st_force_4d(geometry)',
        'FUNCTION st_force_collection(geometry)',
        'FUNCTION st_forcerhr(geometry)',
        'FUNCTION st_gdaldrivers()',
        'FUNCTION st_geogfromtext(text)',
        'FUNCTION st_geogfromwkb(bytea)',
        'FUNCTION st_geographyfromtext(text)',
        'FUNCTION st_geohash(geometry)',
        'FUNCTION st_geohash(geometry,integer)',
        'FUNCTION st_geom_accum(geometry[],geometry)',
        'FUNCTION st_geomcollfromtext(text)',
        'FUNCTION st_geomcollfromtext(text,integer)',
        'FUNCTION st_geomcollfromwkb(bytea)',
        'FUNCTION st_geomcollfromwkb(bytea,integer)',
        'FUNCTION st_geometry_above(geometry,geometry)',
        'FUNCTION st_geometry_analyze(internal)',
        'FUNCTION st_geometry_below(geometry,geometry)',
        'FUNCTION st_geometry(box2d)',
        'FUNCTION st_geometry(box3d)',
        'FUNCTION st_geometry(box3d_extent)',
        'FUNCTION st_geometry(bytea)',
        'FUNCTION st_geometry(chip)',
        'FUNCTION st_geometry_cmp(geometry,geometry)',
        'FUNCTION st_geometry_contained(geometry,geometry)',
        'FUNCTION st_geometry_contain(geometry,geometry)',
        'FUNCTION st_geometry_eq(geometry,geometry)',
        'FUNCTION st_geometryfromtext(text)',
        'FUNCTION st_geometryfromtext(text,integer)',
        'FUNCTION st_geometry_ge(geometry,geometry)',
        'FUNCTION st_geometry_gt(geometry,geometry)',
        'FUNCTION st_geometry_in(cstring)',
        'FUNCTION st_geometry_left(geometry,geometry)',
        'FUNCTION st_geometry_le(geometry,geometry)',
        'FUNCTION st_geometry_lt(geometry,geometry)',
        'FUNCTION st_geometryn(geometry,integer)',
        'FUNCTION st_geometry_out(geometry)',
        'FUNCTION st_geometry_overabove(geometry,geometry)',
        'FUNCTION st_geometry_overbelow(geometry,geometry)',
        'FUNCTION st_geometry_overlap(geometry,geometry)',
        'FUNCTION st_geometry_overleft(geometry,geometry)',
        'FUNCTION st_geometry_overright(geometry,geometry)',
        'FUNCTION st_geometry_recv(internal)',
        'FUNCTION st_geometry_right(geometry,geometry)',
        'FUNCTION st_geometry_same(geometry,geometry)',
        'FUNCTION st_geometry_send(geometry)',
        'FUNCTION st_geometry(text)',
        'FUNCTION st_geometrytype(geometry)',
        'FUNCTION st_geometrytype(topogeometry)',
        'FUNCTION st_geomfromewkb(bytea)',
        'FUNCTION st_geomfromewkt(text)',
        'FUNCTION st_geomfromgeojson(text)',
        'FUNCTION st_geomfromgml(text)',
        'FUNCTION _st_geomfromgml(text,integer)',
        'FUNCTION st_geomfromgml(text,integer)',
        'FUNCTION st_geomfromkml(text)',
        'FUNCTION st_geomfromtext(text)',
        'FUNCTION st_geomfromtext(text,integer)',
        'FUNCTION st_geomfromwkb(bytea)',
        'FUNCTION st_geomfromwkb(bytea,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_georeference(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_georeference(raster,text)',
         # PG12_DEPRECATED
         'FUNCTION st_geotransform(raster)',
        'FUNCTION st_getfaceedges(character varying,integer)',
        'FUNCTION _st_getfacegeometry(character varying,integer)',
        'FUNCTION st_getfacegeometry(character varying,integer)',
        'FUNCTION st_gmltosql(text)',
        'FUNCTION st_gmltosql(text,integer)',
        'FUNCTION st_hasarc(geometry)',
        'FUNCTION st_hasbbox(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_hasnoband(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_hasnoband(raster,integer)',
        'FUNCTION st_hausdorffdistance(geometry,geometry)',
        'FUNCTION st_hausdorffdistance(geometry,geometry,double precision)',
        'FUNCTION st_height(chip)',
         # PG12_DEPRECATED
         'FUNCTION st_height(raster)',
        'FUNCTION _st_hillshade4ma(double precision[],text,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_hillshade(raster,integer,text,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_hillshade(raster,integer,text,double precision,double precision,double precision,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_hillshade(raster,integer,text,float,float,float,float)',
         # PG12_DEPRECATED
         'FUNCTION st_hillshade(raster,integer,text,float,float,float,float,boolean)',
        'FUNCTION st_histogram2d_in(cstring)',
        'FUNCTION st_histogram2d_out(histogram2d)',
         # PG12_DEPRECATED
         'FUNCTION _st_histogram(raster,integer,boolean,double precision,integer,double precision[],boolean,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_histogram(raster,integer,boolean,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_histogram(raster,integer,boolean,integer,double precision[],boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_histogram(raster,integer,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_histogram(raster,integer,integer,double precision[],boolean)',
        'FUNCTION _st_histogram(text,text,integer,boolean,double precision,integer,double precision[],boolean)',
        'FUNCTION st_histogram(text,text,integer,boolean,integer,boolean)',
        'FUNCTION st_histogram(text,text,integer,boolean,integer,double precision[],boolean)',
        'FUNCTION st_histogram(text,text,integer,integer,boolean)',
        'FUNCTION st_histogram(text,text,integer,integer,double precision[],boolean)',
        'FUNCTION st_inittopogeo(character varying)',
        'FUNCTION st_interiorringn(geometry,integer)',
        'FUNCTION st_interpolatepoint(geometry,geometry)',
        'FUNCTION st_intersection(geography,geography)',
        'FUNCTION st_intersection(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(geometry,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,geometry,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,geometry,text,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,geometry,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,geometry,text,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,raster,integer,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,raster,integer,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,raster,integer,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,raster,integer,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,raster,integer,text,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,integer,raster,integer,text,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION _st_intersection(raster,integer,raster,integer,text,text,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,raster,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,raster,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,raster,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,raster,text,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_intersection(raster,raster,text,regprocedure)',
        'FUNCTION st_intersection(text,text)',
        'FUNCTION st_intersects(geography,geography)',
        'FUNCTION _st_intersects(geometry,geometry)',
        'FUNCTION st_intersects(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(geometry,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(geometry,raster,boolean)',
         # PG12_DEPRECATED
         'FUNCTION _st_intersects(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION _st_intersects(geometry,raster,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(geometry,raster,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(raster,boolean,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(raster,geometry)',
         # PG12_DEPRECATED
         'FUNCTION _st_intersects(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(raster,integer,boolean,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(raster,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION _st_intersects(raster,integer,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(raster,integer,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_intersects(raster,raster)',
        'FUNCTION st_intersects(text,text)',
        'FUNCTION st_isclosed(geometry)',
        'FUNCTION st_iscollection(geometry)',
        'FUNCTION st_isempty(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_isempty(raster)',
        'FUNCTION st_isring(geometry)',
        'FUNCTION st_issimple(geometry)',
        'FUNCTION st_isvaliddetail(geometry)',
        'FUNCTION st_isvaliddetail(geometry,integer)',
        'FUNCTION st_isvalid(geometry)',
        'FUNCTION st_isvalid(geometry,integer)',
        'FUNCTION st_isvalidreason(geometry)',
        'FUNCTION st_isvalidreason(geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_left(raster,raster)',
        'FUNCTION st_length2d(geometry)',
        'FUNCTION st_length2d_spheroid(geometry,spheroid)',
        'FUNCTION st_length3d(geometry)',
        'FUNCTION st_length3d_spheroid(geometry,spheroid)',
        'FUNCTION st_length(geography)',
        'FUNCTION st_length(geography,boolean)',
        'FUNCTION st_length(geometry)',
        'FUNCTION st_length_spheroid(geometry,spheroid)',
        'FUNCTION st_length(text)',
        'FUNCTION _st_linecrossingdirection(geometry,geometry)',
        'FUNCTION st_linecrossingdirection(geometry,geometry)',
        'FUNCTION st_linefromencodedpolyline(text)',
        'FUNCTION st_linefromencodedpolyline(text,integer)',
        'FUNCTION st_linefrommultipoint(geometry)',
        'FUNCTION st_linefromtext(text)',
        'FUNCTION st_linefromtext(text,integer)',
        'FUNCTION st_linefromwkb(bytea)',
        'FUNCTION st_linefromwkb(bytea,integer)',
        'FUNCTION st_line_interpolate_point(geometry,double precision)',
        'FUNCTION st_line_locate_point(geometry,geometry)',
        'FUNCTION st_linemerge(geometry)',
        'FUNCTION st_linestringfromwkb(bytea)',
        'FUNCTION st_linestringfromwkb(bytea,integer)',
        'FUNCTION st_line_substring(geometry,double precision,double precision)',
        'FUNCTION st_linetocurve(geometry)',
        'FUNCTION st_locatealong(geometry,double precision)',
        'FUNCTION st_locatealong(geometry,double precision,double precision)',
        'FUNCTION st_locate_along_measure(geometry,double precision)',
        'FUNCTION st_locatebetweenelevations(geometry,double precision,double precision)',
        'FUNCTION st_locatebetween(geometry,double precision,double precision)',
        'FUNCTION st_locatebetween(geometry,double precision,double precision,double precision)',
        'FUNCTION st_locate_between_measures(geometry,double precision,double precision)',
        'FUNCTION _st_longestline(geometry,geometry)',
        'FUNCTION st_longestline(geometry,geometry)',
        'FUNCTION st_makebox2d(geometry,geometry)',
        'FUNCTION st_makebox3d(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_makeemptyraster(integer,integer,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_makeemptyraster(integer,integer,double precision,double precision,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_makeemptyraster(integer,integer,double precision,double precision,double precision,double precision,double precision,double precision,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_makeemptyraster(raster)',
        'FUNCTION st_makeenvelope(double precision,double precision,double precision,double precision)',
        'FUNCTION st_makeenvelope(double precision,double precision,double precision,double precision,integer)',
        'FUNCTION st_makeline_garray(geometry[])',
        'FUNCTION st_makeline(geometry[])',
        'FUNCTION st_makeline(geometry,geometry)',
        'FUNCTION st_makepoint(double precision,double precision)',
        'FUNCTION st_makepoint(double precision,double precision,double precision)',
        'FUNCTION st_makepoint(double precision,double precision,double precision,double precision)',
        'FUNCTION st_makepointm(double precision,double precision,double precision)',
        'FUNCTION st_makepolygon(geometry)',
        'FUNCTION st_makepolygon(geometry,geometry[])',
        'FUNCTION st_makevalid(geometry)',
         # PG12_DEPRECATED
         'FUNCTION _st_mapalgebra4unionfinal1(raster)',
         # PG12_DEPRECATED
         'FUNCTION _st_mapalgebra4unionstate(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION _st_mapalgebra4unionstate(raster,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION _st_mapalgebra4unionstate(raster,raster,integer,text)',
         # PG12_DEPRECATED
         'FUNCTION _st_mapalgebra4unionstate(raster,raster,text)',
         # PG12_DEPRECATED
         'FUNCTION _st_mapalgebra4unionstate(raster,raster,text,text,text,double precision,text,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebraexpr(raster,integer,raster,integer,text,text,text,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebraexpr(raster,integer,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebraexpr(raster,integer,text,text,text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebraexpr(raster,raster,text,text,text,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebraexpr(raster,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebraexpr(raster,text,text,text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafctngb(raster,integer,text,integer,integer,regprocedure,text,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafctngb(raster,integer,text,integer,integer,regprocedure,text,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,raster,integer,regprocedure,text,text,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,raster,integer,regprocedure,text,text,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,regprocedure,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,regprocedure,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,text,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,text,regprocedure,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,integer,text,regprocedure,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,raster,regprocedure,text,text,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,raster,regprocedure,text,text,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION  st_mapalgebrafct(raster,raster,regprocedure,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,regprocedure,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,regprocedure,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,text,regprocedure)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,text,regprocedure,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebrafct(raster,text,regprocedure,variadic text[])',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,integer,text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,integer,text,text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,integer,text,text,nodatavaluerepl text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,integer,text,text,text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,pixeltype text,expression text,nodatavaluerepl text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,text,text)',
         # PG12_DEPRECATED
         'FUNCTION st_mapalgebra(raster,text,text,text)',
        'FUNCTION st_max4ma(double precision[],text,text[])',
        'FUNCTION _st_maxdistance(geometry,geometry)',
        'FUNCTION st_max_distance(geometry,geometry)',
        'FUNCTION st_maxdistance(geometry,geometry)',
        'FUNCTION st_mean4ma(double precision[],text,text[])',
        'FUNCTION st_mem_size(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_metadata(raster)',
        'FUNCTION st_m(geometry)',
        'FUNCTION st_min4ma(double precision[],text,text[])',
        'FUNCTION  st_minimumboundingcircle(geometry)',
        'FUNCTION st_minimumboundingcircle(geometry)',
        'FUNCTION st_minimumboundingcircle(geometry,integer)',
        'FUNCTION st_minpossibleval(text)',
        'FUNCTION st_minpossiblevalue(text)',
        'FUNCTION st_mlinefromtext(text)',
        'FUNCTION st_mlinefromtext(text,integer)',
        'FUNCTION st_mlinefromwkb(bytea)',
        'FUNCTION st_mlinefromwkb(bytea,integer)',
        'FUNCTION st_modedgeheal(character varying,integer,integer)',
        'FUNCTION st_modedgesplit(character varying,integer,public.geometry)',
        'FUNCTION st_modedgessplit(character varying,integer,public.geometry)',
        'FUNCTION st_moveisonode(character varying,integer,public.geometry)',
        'FUNCTION st_mpointfromtext(text)',
        'FUNCTION st_mpointfromtext(text,integer)',
        'FUNCTION st_mpointfromwkb(bytea)',
        'FUNCTION st_mpointfromwkb(bytea,integer)',
        'FUNCTION st_mpolyfromtext(text)',
        'FUNCTION st_mpolyfromtext(text,integer)',
        'FUNCTION st_mpolyfromwkb(bytea)',
        'FUNCTION st_mpolyfromwkb(bytea,integer)',
        'FUNCTION st_multi(geometry)',
        'FUNCTION st_multilinefromwkb(bytea)',
        'FUNCTION st_multilinestringfromtext(text)',
        'FUNCTION st_multilinestringfromtext(text,integer)',
        'FUNCTION st_multipointfromtext(text)',
        'FUNCTION st_multipointfromwkb(bytea)',
        'FUNCTION st_multipointfromwkb(bytea,integer)',
        'FUNCTION st_multipolyfromwkb(bytea)',
        'FUNCTION st_multipolyfromwkb(bytea,integer)',
        'FUNCTION st_multipolygonfromtext(text)',
        'FUNCTION st_multipolygonfromtext(text,integer)',
        'FUNCTION st_ndims(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_nearestvalue(raster,integer,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_nearestvalue(raster,integer,integer,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_neighborhood(raster,geometry,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_neighborhood(raster,integer,geometry,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_neighborhood(raster,integer,integer,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_neighborhood(raster,integer,integer,integer,integer,boolean)',
        'FUNCTION st_newedgeheal(character varying,integer,integer)',
        'FUNCTION st_newedgessplit(character varying,integer,public.geometry)',
        'FUNCTION st_node(geometry)',
        'FUNCTION st_noop(geometry)',
        'FUNCTION st_npoints(geometry)',
        'FUNCTION st_nrings(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_numbands(raster)',
        'FUNCTION st_numgeometries(geometry)',
        'FUNCTION st_numinteriorring(geometry)',
        'FUNCTION st_numinteriorrings(geometry)',
        'FUNCTION st_numpatches(geometry)',
        'FUNCTION st_numpoints(geometry)',
        'FUNCTION st_offsetcurve(geometry,double precision,cstring)',
        'FUNCTION st_offsetcurve(geometry,double precision,text)',
        'FUNCTION _st_orderingequals(geometry,geometry)',
        'FUNCTION st_orderingequals(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_overabove(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_overbelow(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_overlap(raster,raster)',
        'FUNCTION _st_overlaps(geometry,geometry)',
        'FUNCTION st_overlaps(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION _st_overlaps(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_overlaps(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION _st_overlaps(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_overlaps(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_overlaps(raster,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_overleft(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_overright(raster,raster)',
        'FUNCTION st_patchn(geometry,integer)',
        'FUNCTION st_perimeter2d(geometry)',
        'FUNCTION st_perimeter3d(geometry)',
        'FUNCTION st_perimeter(geography)',
        'FUNCTION st_perimeter(geography,boolean)',
        'FUNCTION st_perimeter(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_pixelaspolygon(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_pixelaspolygon(raster,integer,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_pixelaspolygons(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_pixelaspolygons(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_pixelheight(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_pixelwidth(raster)',
        'FUNCTION st_point(double precision,double precision)',
        'FUNCTION st_pointfromtext(text)',
        'FUNCTION st_pointfromtext(text,integer)',
        'FUNCTION st_pointfromwkb(bytea)',
        'FUNCTION st_pointfromwkb(bytea,integer)',
        'FUNCTION st_point_inside_circle(geometry,double precision,double precision,double precision)',
        'FUNCTION st_pointn(geometry)',
        'FUNCTION st_pointn(geometry,integer)',
        'FUNCTION st_pointonsurface(geometry)',
        'FUNCTION _st_pointoutside(geography)',
        'FUNCTION st_polyfromtext(text)',
        'FUNCTION st_polyfromtext(text,integer)',
        'FUNCTION st_polyfromwkb(bytea)',
        'FUNCTION st_polyfromwkb(bytea,integer)',
        'FUNCTION st_polygonfromtext(text)',
        'FUNCTION st_polygonfromtext(text,integer)',
        'FUNCTION st_polygonfromwkb(bytea)',
        'FUNCTION st_polygonfromwkb(bytea,integer)',
        'FUNCTION st_polygon(geometry,integer)',
        'FUNCTION st_polygonize_garray(geometry[])',
        'FUNCTION st_polygonize(geometry[])',
         # PG12_DEPRECATED
         'FUNCTION st_polygon(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_polygon(raster,integer)',
        'FUNCTION st_postgis_gist_joinsel(internal,oid,internal,smallint)',
        'FUNCTION st_postgis_gist_sel(internal,oid,internal,integer)',
        'FUNCTION st_project(geography,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_quantile(raster,boolean,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_quantile(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_quantile(raster,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_quantile(raster,integer,boolean,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_quantile(raster,integer,boolean,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION _st_quantile(raster,integer,boolean,double precision,double precision[])',
         # PG12_DEPRECATED
         'FUNCTION st_quantile(raster,integer,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_quantile(raster,integer,double precision[])',
        'FUNCTION st_quantile(text,text,boolean,double precision)',
        'FUNCTION st_quantile(text,text,double precision)',
        'FUNCTION st_quantile(text,text,double precision[])',
        'FUNCTION st_quantile(text,text,integer,boolean,double precision)',
        'FUNCTION st_quantile(text,text,integer,boolean,double precision[])',
        'FUNCTION _st_quantile(text,text,integer,boolean,double precision,double precision[])',
        'FUNCTION st_quantile(text,text,integer,double precision)',
        'FUNCTION st_quantile(text,text,integer,double precision[])',
        'FUNCTION st_range4ma(double precision[],text,text[])',
         # PG12_DEPRECATED
         'FUNCTION _st_raster2worldcoord(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_raster2worldcoord(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_raster2worldcoordx(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_raster2worldcoordx(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_raster2worldcoordy(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_raster2worldcoordy(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_reclass(raster,integer,text,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION _st_reclass(raster,reclassarg[])',
         # PG12_DEPRECATED
         'FUNCTION st_reclass(raster,reclassarg[])',
         # PG12_DEPRECATED
         'FUNCTION st_reclass(raster,text,text)',
        'FUNCTION st_relate(geometry,geometry)',
        'FUNCTION st_relate(geometry,geometry,integer)',
        'FUNCTION st_relate(geometry,geometry,text)',
        'FUNCTION st_relatematch(text,text)',
        'FUNCTION st_remedgemodface(character varying,integer)',
        'FUNCTION st_remedgenewface(character varying,integer)',
        'FUNCTION st_remisonode(character varying,integer)',
        'FUNCTION st_removeisoedge(character varying,integer)',
        'FUNCTION st_removeisonode(character varying,integer)',
        'FUNCTION st_removepoint(geometry,integer)',
        'FUNCTION st_removerepeatedpoints(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_resample(raster,integer,double precision,double precision,double precision,double precision,double precision,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_resample(raster,integer,integer,integer,double precision,double precision,double precision,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_resample(raster,raster,boolean,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_resample(raster,raster,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_resample(raster,raster,text,double precision,boolean)',
         # PG12_DEPRECATED
         'FUNCTION _st_resample(raster,text,double precision,integer,double precision,double precision,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION _st_resample(raster,text,double precision,integer,double precision,double precision,double precision,double precision,double precision,double precision,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_rescale(raster,double precision,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_rescale(raster,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_reskew(raster,double precision,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_reskew(raster,double precision,text,double precision)',
        'FUNCTION st_reverse(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_right(raster,raster)',
        'FUNCTION st_rotate(geometry,double precision)',
        'FUNCTION st_rotate(geometry,double precision,double precision,double precision)',
        'FUNCTION st_rotate(geometry,double precision,geometry)',
        'FUNCTION st_rotatex(geometry,double precision)',
        'FUNCTION st_rotatey(geometry,double precision)',
        'FUNCTION st_rotatez(geometry,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_rotation(raster)',
        'FUNCTION st_samealignment(double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_samealignment(raster,raster)',
         # PG12_DEPRECATED
         'FUNCTION st_same(raster,raster)',
        'FUNCTION st_scale(geometry,double precision,double precision)',
        'FUNCTION st_scale(geometry,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_scalex(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_scaley(raster)',
        'FUNCTION st_segmentize(geometry,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setbandisnodata(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_setbandisnodata(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_setbandnodatavalue(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setbandnodatavalue(raster,integer,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setbandnodatavalue(raster,integer,double precision,boolean)',
        'FUNCTION st_setfactor(chip,real)',
         # PG12_DEPRECATED
         'FUNCTION st_setgeoreference(raster,text)',
         # PG12_DEPRECATED
         'FUNCTION st_setgeoreference(raster,text,text)',
         # PG12_DEPRECATED
         'FUNCTION st_setgeotransform(raster,double precision,double precision,double precision,double precision,double precision,double precision)',
        'FUNCTION st_setpoint(geometry,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_setrotation(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setscale(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setscale(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setskew(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setskew(raster,double precision,double precision)',
        'FUNCTION st_setsrid(geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_setsrid(raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_setupperleft(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setvalue(raster,geometry,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setvalue(raster,integer,geometry,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setvalue(raster,integer,integer,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_setvalue(raster,integer,integer,integer,double precision)',
        'FUNCTION st_sharedpaths(geometry,geometry)',
        'FUNCTION st_shift_longitude(geometry)',
        'FUNCTION st_shortestline(geometry,geometry)',
        'FUNCTION st_simplify(geometry,double precision)',
        'FUNCTION st_simplifypreservetopology(geometry,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_skewx(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_skewy(raster)',
        'FUNCTION _st_slope4ma(double precision[],text,text[])',
         # PG12_DEPRECATED
         'FUNCTION st_slope(raster,integer,text)',
         # PG12_DEPRECATED
         'FUNCTION st_slope(raster,integer,text,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_slope(raster,integer,text,text,double precision,boolean)',
        'FUNCTION st_snap(geometry,geometry,double precision)',
        'FUNCTION st_snaptogrid(geometry,double precision)',
        'FUNCTION st_snaptogrid(geometry,double precision,double precision)',
        'FUNCTION st_snaptogrid(geometry,double precision,double precision,double precision,double precision)',
        'FUNCTION st_snaptogrid(geometry,geometry,double precision,double precision,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_snaptogrid(raster,double precision,double precision,double precision,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_snaptogrid(raster,double precision,double precision,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_snaptogrid(raster,double precision,double precision,text,double precision,double precision,double precision)',
        'FUNCTION st_spheroid_in(cstring)',
        'FUNCTION st_spheroid_out(spheroid)',
        'FUNCTION st_split(geometry,geometry)',
        'FUNCTION st_srid(chip)',
        'FUNCTION st_srid(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_srid(raster)',
        'FUNCTION st_startpoint(geometry)',
        'FUNCTION st_sum4ma(double precision[],text,text[])',
        'FUNCTION st_summary(geography)',
        'FUNCTION st_summary(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_summarystats(raster,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_summarystats(raster,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION _st_summarystats(raster,integer,boolean,double precision)',
        'FUNCTION st_summarystats(text,text,boolean)',
        'FUNCTION st_summarystats(text,text,integer,boolean)',
        'FUNCTION _st_summarystats(text,text,integer,boolean,double precision)',
        'FUNCTION st_symdifference(geometry,geometry)',
        'FUNCTION st_symmetricdifference(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_testraster(double precision,double precision,double precision)',
        'FUNCTION st_text(boolean)',
        'FUNCTION st_text(geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_tile(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION _st_tile(raster,integer,integer,integer[])',
         # PG12_DEPRECATED
         'FUNCTION st_tile(raster,integer,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_tile(raster,integer,integer,integer[])',
         # PG12_DEPRECATED
         'FUNCTION st_tile(raster,integer[],integer,integer)',
        'FUNCTION _st_touches(geometry,geometry)',
        'FUNCTION st_touches(geometry,geometry)',
         # PG12_DEPRECATED
         'FUNCTION _st_touches(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_touches(geometry,raster,integer)',
         # PG12_DEPRECATED
         'FUNCTION _st_touches(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_touches(raster,geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_touches(raster,integer,geometry)',
        'FUNCTION st_transform(geometry,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_transform(raster,integer,double precision,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_transform(raster,integer,double precision,text,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_transform(raster,integer,text,double precision,double precision,double precision)',
        'FUNCTION st_translate(geometry,double precision,double precision)',
        'FUNCTION st_translate(geometry,double precision,double precision,double precision)',
        'FUNCTION st_transscale(geometry,double precision,double precision,double precision,double precision)',
        'FUNCTION st_unaryunion(geometry)',
        'FUNCTION st_union(geometry[])',
        'FUNCTION st_union(geometry,geometry)',
        'FUNCTION st_unite_garray(geometry[])',
         # PG12_DEPRECATED
         'FUNCTION st_upperleftx(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_upperlefty(raster)',
         # PG12_DEPRECATED
         'FUNCTION st_valuecount(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuecount(raster,double precision[],double precision)',
         # PG12_DEPRECATED
         'FUNCTION _st_valuecount(raster,integer,boolean,double precision[],double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuecount(raster,integer,boolean,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuecount(raster,integer,boolean,double precision[],double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuecount(raster,integer,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuecount(raster,integer,double precision[],double precision)',
        'FUNCTION st_valuecount(text,text,double precision,double precision)',
        'FUNCTION st_valuecount(text,text,double precision[],double precision)',
        'FUNCTION _st_valuecount(text,text,integer,boolean,double precision[],double precision)',
        'FUNCTION st_valuecount(text,text,integer,boolean,double precision,double precision)',
        'FUNCTION st_valuecount(text,text,integer,boolean,double precision[],double precision)',
        'FUNCTION st_valuecount(text,text,integer,double precision,double precision)',
        'FUNCTION st_valuecount(text,text,integer,double precision[],double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuepercent(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuepercent(raster,double precision[],double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuepercent(raster,integer,boolean,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuepercent(raster,integer,boolean,double precision[],double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuepercent(raster,integer,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_valuepercent(raster,integer,double precision[],double precision)',
        'FUNCTION st_valuepercent(text,text,double precision,double precision)',
        'FUNCTION st_valuepercent(text,text,double precision[],double precision)',
        'FUNCTION st_valuepercent(text,text,integer,boolean,double precision,double precision)',
        'FUNCTION st_valuepercent(text,text,integer,boolean,double precision[],double precision)',
        'FUNCTION st_valuepercent(text,text,integer,double precision,double precision)',
        'FUNCTION st_valuepercent(text,text,integer,double precision[],double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,geometry,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,geometry,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,integer,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,integer,geometry,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,integer,geometry,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,integer,integer,boolean)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,integer,integer,integer)',
         # PG12_DEPRECATED
         'FUNCTION st_value(raster,integer,integer,integer,boolean)',
        'FUNCTION st_width(chip)',
         # PG12_DEPRECATED
         'FUNCTION st_width(raster)',
        'FUNCTION _st_within(geometry,geometry)',
        'FUNCTION st_within(geometry,geometry)',
        'FUNCTION st_wkbtosql(bytea)',
        'FUNCTION st_wkttosql(text)',
         # PG12_DEPRECATED
         'FUNCTION _st_world2rastercoord(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoord(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoord(raster,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoordx(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoordx(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoordx(raster,geometry)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoordy(raster,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoordy(raster,double precision,double precision)',
         # PG12_DEPRECATED
         'FUNCTION st_world2rastercoordy(raster,geometry)',
        'FUNCTION st_x(geometry)',
        'FUNCTION st_xmax(box3d)',
        'FUNCTION st_xmin(box3d)',
        'FUNCTION st_y(geometry)',
        'FUNCTION st_ymax(box3d)',
        'FUNCTION st_ymin(box3d)',
        'FUNCTION st_z(geometry)',
        'FUNCTION st_zmax(box3d)',
        'FUNCTION st_zmflag(geometry)',
        'FUNCTION st_zmin(box3d)',
        'FUNCTION summary(geometry)',
        'FUNCTION symdifference(geometry,geometry)',
        'FUNCTION symmetricdifference(geometry,geometry)',
        'FUNCTION text(boolean)',
        'FUNCTION text(geometry)',
        'FUNCTION topoelementarray_append(topoelementarray,topoelement)',
        'FUNCTION topogeo_addgeometry(character varying,public.geometry,double precision)',
        'FUNCTION topogeo_addlinestring(character varying,public.geometry)',
        'FUNCTION topogeo_addlinestring(character varying,public.geometry,double precision)',
        'FUNCTION topogeo_addpoint(character varying,public.geometry,double precision)',
        'FUNCTION topogeo_addpoint(character varying,public.geometry,integer,integer)',
        'FUNCTION topogeo_addpolygon(character varying,public.geometry)',
        'FUNCTION topogeo_addpolygon(character varying,public.geometry,double precision)',
        'FUNCTION topologysummary(character varying)',
        'FUNCTION totopogeom(public.geometry,character varying,integer,double precision)',
        'FUNCTION touches(geometry,geometry)',
        'FUNCTION transform_geometry(geometry,text,text,integer)',
        'FUNCTION transform(geometry,integer)',
        'FUNCTION translate(geometry,double precision,double precision)',
        'FUNCTION translate(geometry,double precision,double precision,double precision)',
        'FUNCTION transscale(geometry,double precision,double precision,double precision,double precision)',
        'FUNCTION unite_garray(geometry[])',
        'FUNCTION unlockrows(text)',
        'FUNCTION updategeometrysrid(character varying,character varying,character varying,character varying,integer)',
        'FUNCTION updategeometrysrid(character varying,character varying,character varying,integer)',
        'FUNCTION updategeometrysrid(character varying,character varying,integer)',
        'FUNCTION update_geometry_stats()',
        'FUNCTION update_geometry_stats(character varying,character varying)',
        'FUNCTION validatetopology(character varying)',
        'FUNCTION width(chip)',
        'FUNCTION within(geometry,geometry)',
        'FUNCTION x(geometry)',
        'FUNCTION xmax(box2d)',
        'FUNCTION xmax(box3d)',
        'FUNCTION xmin(box2d)',
        'FUNCTION xmin(box3d)',
        'FUNCTION y(geometry)',
        'FUNCTION ymax(box2d)',
        'FUNCTION ymax(box3d)',
        'FUNCTION ymin(box2d)',
        'FUNCTION ymin(box3d)',
        'FUNCTION z(geometry)',
        'FUNCTION zmax(box3d)',
        'FUNCTION zmflag(geometry)',
        'FUNCTION zmin(box3d)',
        'FUNCTION st_astext(bytea)',
        'FUNCTION st_length_spheroid3d(geometry,spheroid)',
        'FUNCTION st_generatepoints(geometry,numeric)',
        'OPERATOR CLASS btree_geography_ops',
        'OPERATOR CLASS btree_geometry_ops',
        'OPERATOR CLASS gist_geography_ops',
        'OPERATOR CLASS gist_geometry_ops',
        'OPERATOR CLASS gist_geometry_ops_2d',
        'OPERATOR CLASS gist_geometry_ops_nd',
        'OPERATOR FAMILY btree_geography_ops',
        'OPERATOR FAMILY btree_geometry_ops',
        'OPERATOR FAMILY gist_geography_ops',
        'OPERATOR FAMILY gist_geometry_ops_2d',
        'OPERATOR FAMILY gist_geometry_ops_nd',
         # PG12_DEPRECATED
         'OPERATOR FAMILY hash_raster_ops',
        'OPERATOR ~=(geography,geography)',
        'OPERATOR ~(geography,geography)',
        'OPERATOR <<|(geography,geography)',
        'OPERATOR <<(geography,geography)',
        'OPERATOR <=(geography,geography)',
        'OPERATOR <(geography,geography)',
        'OPERATOR =(geography,geography)',
        'OPERATOR >=(geography,geography)',
        'OPERATOR >>(geography,geography)',
        'OPERATOR >(geography,geography)',
        'OPERATOR |>>(geography,geography)',
        'OPERATOR |&>(geography,geography)',
        'OPERATOR @(geography,geography)',
        'OPERATOR &<|(geography,geography)',
        'OPERATOR &<(geography,geography)',
        'OPERATOR &>(geography,geography)',
        'OPERATOR &&(geography,geography)',
        'OPERATOR &&&(geography,geography)',
        'OPERATOR ~=(geometry,geometry)',
        'OPERATOR ~(geometry,geometry)',
        'OPERATOR <<|(geometry,geometry)',
        'OPERATOR <<(geometry,geometry)',
        'OPERATOR <=(geometry,geometry)',
        'OPERATOR <->(geometry,geometry)',
        'OPERATOR <(geometry,geometry)',
        'OPERATOR <#>(geometry,geometry)',
        'OPERATOR =(geometry,geometry)',
        'OPERATOR >=(geometry,geometry)',
        'OPERATOR >>(geometry,geometry)',
        'OPERATOR >(geometry,geometry)',
        'OPERATOR |>>(geometry,geometry)',
        'OPERATOR |&>(geometry,geometry)',
        'OPERATOR @(geometry,geometry)',
        'OPERATOR &<|(geometry,geometry)',
        'OPERATOR &<(geometry,geometry)',
        'OPERATOR &>(geometry,geometry)',
        'OPERATOR &&(geometry,geometry)',
        'OPERATOR &&&(geometry,geometry)',
         # PG12_DEPRECATED
         'OPERATOR ~(geometry,raster)',
         # PG12_DEPRECATED
         'OPERATOR &&(geometry,raster)',
         # PG12_DEPRECATED
         'OPERATOR ~(raster,geometry)',
         # PG12_DEPRECATED
         'OPERATOR &&(raster,geometry)',
         # PG12_DEPRECATED
         'OPERATOR ~=(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR ~(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR <<|(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR <<(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR >>(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR |>>(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR |&>(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR @(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR &<|(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR &<(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR &>(raster,raster)',
         # PG12_DEPRECATED
         'OPERATOR &&(raster,raster)',
        'PROCEDURALLANGUAGE plpgsql',
        'SHELLTYPE box2d',
        'SHELLTYPE box2df',
        'SHELLTYPE box3d',
        'SHELLTYPE box3d_extent',
        'SHELLTYPE chip',
        'SHELLTYPE geography',
        'SHELLTYPE geometry',
        'SHELLTYPE gidx',
        'SHELLTYPE pgis_abs',
         # PG12_DEPRECATED
         'SHELLTYPE raster',
        'SHELLTYPE spheroid',
        'TYPE box2d',
        'TYPE box2df',
        'TYPE box3d',
        'TYPE box3d_extent',
        'TYPE chip',
        'TYPE geography',
        'TYPE geometry',
        'TYPE geometry_dump',
        'TYPE geomval',
        'TYPE getfaceedges_returntype',
        'TYPE gidx',
        'TYPE histogram',
        'TYPE histogram2d',
        'TYPE pgis_abs',
        'TYPE quantile',
         # PG12_DEPRECATED
         'TYPE raster',
         # PG12_DEPRECATED
         'TYPE rastexpr',
        'TYPE reclassarg',
        'TYPE spheroid',
        'TYPE summarystats',
        'TYPE topogeometry',
        'TYPE validatetopology_returntype',
        'TYPE valid_detail',
        'TYPE valuecount',
        'TYPE wktgeomval',
        'FUNCTION update_timestamp()'
      ].freeze

      def remove_line?(line)
        arguments, name, type = matches(line)
        return true if type == 'ACL' && legacy_functions.flat_map { |_, v| v[name] }.compact.include?(arguments)
        return false unless legacy_functions[type]
        return false unless legacy_functions[type][name]
        if arguments.blank?
          legacy_functions[type].include?(name)
        else
          legacy_functions[type][name].include?(arguments)
        end
      end

      def legacy_functions
        @legacy_functions ||= LEGACY_FUNCTIONS.reduce({}) do |res, line|
          arguments, name, type = matches(line)
          return res unless type && name
          res[type] = {} unless res[type]
          res[type][name] = [] unless res[type][name]
          res[type][name] << arguments if arguments
          res
        end
      end

      def matches(line)
        stripped = line.gsub(/(public|postgres|\"|\*)/, "").strip
        return false unless stripped =~ SIGNATURE_RE
        match = stripped.match(SIGNATURE_RE)
        type = match[:type].strip.gsub(/\s+/, ' ')
        name = match[:name].split(/[\s.]/).last
        arguments = match[:arguments]
        arguments = arguments ? arguments.split(',').map { |arg| arg.split(/[\s.]/).last } : nil
        [arguments, name, type]
      end
    end
  end
end
