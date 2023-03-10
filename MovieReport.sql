
/*

***********************************************************************************************************************************************************************

									MOVIE REPORT

***********************************************************************************************************************************************************************

*/

/* Udemy-Ömer Çolakoğlu, Alıştırmalarla SQL Öğreniyorum Kursu aracılığıyla geliştirilmiştir.  */
/* Ömer Çolakoğlu Hocamın Kaggle'da bulunan TMDB Movie veri seti kullanılmıştır. */
/* Veri seti linki: https://www.kaggle.com/datasets/omercolakoglu/tmdb-website-movie-database */

--Sorgu 1: TMDB sitesinde veri tabanındaki herhangi bir filme ait verileri tek satır olarak veri tabanından çekiniz.

SELECT TITLE+'(' +CONVERT(VARCHAR,YEAR(RELEASE_DATE))+ ')' AS TITLE,
       RELEASE_DATE,
       CONVERT(VARCHAR,RUNTIME/60)+'h' + CONVERT(VARCHAR,RUNTIME%60)+'m' AS DURATION, 
       VOTE_AVERAGE*10 AS VOTE_AVERAGE, 
       TAGLINE,
       OVERVIEW,
       POSTER_PATH,
       (
	   SELECT GENRE + ','
           FROM MOVIE_GENRE MG
           INNER JOIN GENRE G
           ON G.GENREID=MG.GENREID
           WHERE MG.FILMID= M.FILMID 
           FOR XML PATH ('')
       ) GENRES,
       (
           SELECT P.NAME_+' ('+J.JOB+')'+','
           FROM CREW_CREDIT CC
           INNER JOIN DEPARTMENT D 
           ON D.ID = CC.DEPARTMENTID
           INNER JOIN JOB J
           ON J.ID = CC.JOBID
           INNER JOIN PERSON P
           ON P.PERSONID = CC.PERSONID
           WHERE FILMID=M.FILMID AND J.JOB IN ('Director', 'Screenplay')
        FOR XML PATH ('')
        ) CREW
FROM MOVIE M
WHERE M.FILMID=98


--Sorgu 2: TMDB sitesinde veri tabanındaki herhangi bir filme ait verileri veri tabanından çekiniz.

--Film Genel Bilgi
SELECT TITLE+'(' +CONVERT(VARCHAR,YEAR(RELEASE_DATE))+ ')' AS TITLE,
        RELEASE_DATE,	
        CONVERT(VARCHAR,RUNTIME/60)+'h' + CONVERT(VARCHAR,RUNTIME%60)+'m' AS DURATION, 
	VOTE_AVERAGE*10 AS VOTE_AVERAGE, 
	TAGLINE,
	OVERVIEW
FROM MOVIE
WHERE TITLE lIKE 'Gladiator' AND FILMID=98

--Yönetmen ve Senaristler
SELECT M.TITLE, 
       P.NAME_,
       D.DEPARTMENT,
       J.JOB
FROM CREW_CREDIT CC
INNER JOIN MOVIE M
ON M.FILMID=CC.FILMID
INNER JOIN PERSON P
ON P.PERSONID=CC.PERSONID
INNER JOIN DEPARTMENT D
ON D.ID =CC.DEPARTMENTID
INNER JOIN JOB j
ON J.ID = CC.JOBID
WHERE M.FILMID=98 
--AND J.JOB IN ('Director', 'Screenplay')

--Oyuncuları
SELECT M.TITLE, 
       P.NAME_,
       P.PROFILE_PATH,
       CC.CHARACTER_,
       CC.ORDER_
FROM CAST_CREDIT CC
INNER JOIN MOVIE M
ON M.FILMID=CC.FILMID
INNER JOIN PERSON P 
ON P.PERSONID=CC.PERSONID
WHERE M.FILMID=98
ORDER BY ORDER_

--Anahtar Kelimeler, Etiketler
SELECT M.TITLE,MK.KEYWORD
FROM MOVIE_KEYWORD MK
INNER JOIN MOVIE M
ON MK.FILMID = M.FILMID
WHERE MK.FILMID=98

--Değerlendirmeler
SELECT M.TITLE,
       MR.*
FROM MOVIE_REVIEW MR
INNER JOIN MOVIE M
ON MR.FILMID=M.FILMID
WHERE M.FILMID=98

--Sorgu 3: TMDB sitesinde veri tabanındaki herhangi bir kişiye ait verileri tek satır olarak veri tabanından çekiniz.

--Temel Kişi Bilgileri
SELECT NAME_,
       BIRTHDAY,
       DATEDIFF(DAY,BIRTHDAY,GETDATE())/365 AS AGE,
       BIOGRAPHY,
       ALSO_KNOWN_AS,
       CASE 
	      WHEN GENDER=2 THEN 'MALE'
	      WHEN GENDER=1 THEN 'FEMALE'
       END AS GENDER,
       PLACE_OF_BIRTH,
       COUNTRY,
       PROFILE_PATH,
       POPULARITY,
       (
	   SELECT COUNT(*)
	   FROM CAST_CREDIT
	   WHERE PERSONID=P.PERSONID 
	   ) AS CASTCREDITCOUNT,
	   
	(  SELECT COUNT(*)
	   FROM CREW_CREDIT
	   WHERE PERSONID=P.PERSONID
	   ) AS CREWCREDITCOUNT
FROM PERSON P
WHERE NAME_ LIKE 'Denzel Washington'

--Oynamış olduğu filmler
SELECT 'Acting' AS TYPE_,
       YEAR(M.RELEASE_DATE) AS YEAR_,
       M.TITLE,
       CC.CHARACTER_
FROM CAST_CREDIT CC
INNER JOIN PERSON P
ON CC.PERSONID= P.PERSONID
INNER JOIN MOVIE M
ON CC.FILMID= M.FILMID
WHERE P.PERSONID=5292
ORDER BY M.RELEASE_DATE DESC

--Production AND Directing
SELECT YEAR(M.RELEASE_DATE) AS YEAR_,
       M.TITLE,
       D.DEPARTMENT,
       j.JOB
FROM CREW_CREDIT CC
INNER JOIN PERSON P
ON CC.PERSONID= P.PERSONID
INNER JOIN MOVIE M
ON CC.FILMID= M.FILMID
INNER JOIN DEPARTMENT D
ON D.ID= CC.DEPARTMENTID
INNER JOIN JOB J
ON J.ID = CC.JOBID
WHERE P.PERSONID=5292
ORDER BY D.DEPARTMENT DESC, M.RELEASE_DATE DESC

--En çok bilindiği|popüler olduğu filmler
SELECT TOP 10
       YEAR(M.RELEASE_DATE) AS YEAR_,
       M.TITLE,
       CC.CHARACTER_,
       M.POPULARITY
FROM CAST_CREDIT CC
INNER JOIN PERSON P
ON CC.PERSONID= P.PERSONID
INNER JOIN MOVIE M
ON CC.FILMID= M.FILMID
WHERE P.PERSONID=5292
ORDER BY M.POPULARITY DESC


--Sorgu 4: Harry Potter, James Bond gibi seri filmlerin kaç filmden oluştuğunu, toplamda ne kadar bütçe ile çekildiğini ve ne kadar hasılat yaptığını çeken sorguyu yazınız.
SELECT C.NAME_ AS SERI_ADI,
       COUNT(M.FILMID) AS FILM_SAYISI,
       SUM(M.BUDGET) AS TOPLAM_BUTCE,
       ROUND(AVG(M.BUDGET),0) AS ORTALAMA_BUTCE,
       SUM(M.REVENUE) AS TOPLAM_HASILAT,
       ROUND(AVG(M.REVENUE),0) AS ORTALAMA_HASILAT
FROM COLLECTION_ C
JOIN MOVIE M 
ON C.COLLECTIONID=M.COLLECTIONID
--WHERE C.NAME_ LIKE 'JAMES BOND%'
GROUP BY C.NAME_
--ORDER BY 3 DESC --Toplam bütçe değerine göre sırala
ORDER BY 4 DESC   --Ortalama bütçe değerine göre sırala


--Sorgu 5: Harry Potter, James Bond gibi seri filmlerin en çok bütçeli, en az bütçeli, en çok hasılat yapan, en az hasılat yapan filmlerini getiren sorguyu yazınız.
SELECT 
C.NAME_ AS SERI_ADI,
(
  SELECT COUNT(*)
  FROM MOVIE
  WHERE COLLECTIONID=C.COLLECTIONID
) AS FILM_SAYISI,
(
  SELECT SUM(BUDGET)
  FROM MOVIE
  WHERE COLLECTIONID=C.COLLECTIONID
) AS TOPLAM_BUTCE,
(
  SELECT SUM(REVENUE)
  FROM MOVIE
  WHERE COLLECTIONID=C.COLLECTIONID
) AS TOPLAM_HASILAT,
(
  SELECT TOP 1 TRIM(STR(YEAR(RELEASE_DATE)))+'-'+ TITLE+','+STR(BUDGET)
  FROM MOVIE
  WHERE COLLECTIONID=C.COLLECTIONID
  ORDER BY BUDGET DESC
) AS ENCOK_BUTCELI_FILM,
(
  SELECT TOP 1 STR(YEAR(RELEASE_DATE))+'-'+ TITLE+','+STR(BUDGET)
  FROM MOVIE
  WHERE COLLECTIONID=C.COLLECTIONID
  ORDER BY BUDGET 
) AS ENAZ_BUTCELI_FILM,
(
  SELECT TOP 1 TRIM(STR(YEAR(RELEASE_DATE)))+'-'+ TITLE+','+STR(REVENUE)
  FROM MOVIE
  WHERE COLLECTIONID=C.COLLECTIONID
  ORDER BY REVENUE DESC
) AS ENCOK_HASILATYAPAN_FILM,
(
  SELECT TOP 1 TRIM(STR(YEAR(RELEASE_DATE)))+'-'+ TITLE+','+STR(REVENUE)
  FROM MOVIE
  WHERE COLLECTIONID=C.COLLECTIONID
  ORDER BY REVENUE ASC
) AS ENDUSUK_HASILATYAPAN_FILM
FROM COLLECTION_ C
--ORDER BY 2 DESC -- Film sayısına göre sırala
ORDER BY 3 DESC --Bütçeye göre sırala
--ORDER BY 4 DESC --Hasılata göre göre sırala


--Sorgu 6: Dünyaca ünlü yönetmen Quentin Tarantino isimli kişinin bu zamana kadar hangi görevde kaç filmde çalıştığı bilgisini getiren sorguyu yazınız.
SELECT P.NAME_ AS KISI,
       D.DEPARTMENT AS BOLUM,
       J.JOB AS GOREV,
       COUNT(M.FILMID) AS FILMSAYISI
FROM PERSON P
JOIN CREW_CREDIT CC
ON CC.PERSONID=P.PERSONID
JOIN DEPARTMENT D
ON D.ID =CC.DEPARTMENTID
JOIN JOB J
ON J.ID = CC.JOBID
JOIN MOVIE M
ON M.FILMID =CC.FILMID
WHERE P.NAME_ LIKE 'Quentin Tarantino%'
GROUP BY P.NAME_,D.DEPARTMENT,J.JOB
ORDER BY D.DEPARTMENT,J.JOB


--Sorgu 7: Hangi ülkenin ne kadar film ürettiği bilgisini getiren sorguyu yazınız.
SELECT MC.COUNTRYCODE AS ULKEKODU,
       C.COUNTRY AS ULKEADI,
       COUNT(M.FILMID) AS FILMSAYISI
FROM MOVIE_COUNTRY MC
JOIN MOVIE M
ON M.FILMID=MC.FILMID
JOIN COUNTRY C
ON C.CODE=MC.COUNTRYCODE
GROUP BY MC.COUNTRYCODE,C.COUNTRY
ORDER BY 3 DESC --Film sayısına göre sırala.

--Türkiye'ye ait filmler
SELECT MC.COUNTRYCODE AS ULKEKODU,
       C.COUNTRY AS ULKEADI,
       M.TITLE,
       M.ORIGINAL_TITLE
FROM MOVIE_COUNTRY MC
JOIN MOVIE M
ON M.FILMID=MC.FILMID
JOIN COUNTRY C
ON C.CODE=MC.COUNTRYCODE
WHERE C.COUNTRY= 'Turkey'

--Sorgu 8: Amerikalı ve Japon şirketlerin birlikte yapımcılığını yaptığı filmleri listeleyin.
SELECT 
       MC.COUNTRYCODE AS ULKEKODU,
       C.COUNTRY AS ULKEADI,
       M.TITLE,
       M.ORIGINAL_TITLE
FROM MOVIE_COUNTRY MC
JOIN MOVIE M
ON M.FILMID=MC.FILMID
JOIN COUNTRY C
ON C.CODE=MC.COUNTRYCODE
WHERE C.CODE= 'US'
--AND M.FILMID=497582
AND M.FILMID IN (SELECT FILMID
                 FROM MOVIE_COUNTRY
		 WHERE COUNTRYCODE='JP')

SELECT *
FROM MOVIE_COUNTRY WHERE FILMID=497582

SELECT *
FROM MOVIE_COUNTRY WHERE FILMID=193726

--Sorgu 9: Her film kategorisinin en popüler 5 filmini getiren sorguyu yazınız.
SELECT 
       GN.GENRE AS KATEGORİ,
       CONVERT(VARCHAR,MV.ROWNR)+'.'+ MV.TITLE AS FILMADI,
       MV.POPULARITY AS POPULARITE
FROM GENRE GN
CROSS APPLY
(
SELECT TOP 5
       ROW_NUMBER() OVER (ORDER BY POPULARITY DESC) AS ROWNR,
       M.TITLE,
       M.FILMID,
       G.GENREID,
       G.GENRE,
       M.POPULARITY
FROM MOVIE_GENRE MG
JOIN GENRE G
ON G.GENREID=MG.GENREID
JOIN MOVIE M
ON M.FILMID=MG.FILMID
WHERE --G.GENRE='Action'
      --G.GENRE='Adventure'
	G.GENREID=GN.GENREID
ORDER BY M.POPULARITY DESC
) AS MV

SELECT *
FROM MOVIE
WHERE TITLE LIKE 'Gladiator'


