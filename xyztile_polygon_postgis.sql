drop table if exists xyztile_polygon;

--テーブルを作る
create table xyztile_polygon (
 geom GEOMETRY (POLYGON, 3857), --ジオメトリ
 x integer, --タイルのX番号
 y integer, --タイルのY番号
 z integer --ズームレベル
);

--データをテーブルにinsertする

--insertする関数を定義
drop function if exists insert_polygon();

create function insert_polygon() returns integer as $$
DECLARE
 zoom integer := 2;     --zoom level
 i integer;
 j integer;
 xl numeric;
 xr numeric;
 yt numeric;
 yb numeric;
 maxxynum integer := 2^zoom -1;
 maxxyval numeric := 6378137 * pi();
 tilelength numeric := maxxyval / (2^(zoom -1));
BEGIN
 for i in 0..maxxynum loop
  xl := (-1) * maxxyval + tilelength * i;
  xr := (-1) * maxxyval + tilelength * (i + 1);
 
  for j in 0..maxxynum loop
    yt :=  maxxyval - tilelength * j;
    yb :=  maxxyval - tilelength * (j + 1);
     INSERT into xyztile_polygon values(ST_GeomFromText('POLYGON((' || xl || ' ' || yt || ',' || xl || ' ' || yb || ',' || xr || ' ' || yb || ',' || xr || ' ' || yt || ',' || xl || ' ' || yt || '))',3857),i,j,zoom);
  end loop;
 end loop;
 return 0;
end;
$$ language plpgsql;

--関数を実行する
select insert_polygon();