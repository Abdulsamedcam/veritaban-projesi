--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3
-- Dumped by pg_dump version 12rc1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: musterinin_toplam_siparis_sayisi(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.musterinin_toplam_siparis_sayisi(kisi_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$-- idsi girilen müşteri kaç kere sipsariş vermiş onu gösterir
-- örnek 20 denene bilir
declare
	total integer;
BEGIN
   SELECT count(siparis_id)  into total FROM siparisler where musteri_id = kisi_id;
   RETURN total;
END;
$$;


ALTER FUNCTION public.musterinin_toplam_siparis_sayisi(kisi_id integer) OWNER TO postgres;

--
-- Name: process_log_after_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_log_after_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
declare
id int;
	Begin	
	
	if  tg_table_name = 'urunler' then
	id = old.urun_id;
	elseif tg_table_name = 'musteri' then
	id = old.musteri_no;
	end if;
	
	--RAISE NOTICE 'insert işlemi ypıldı index_id %  tbl % usr %', new.index_id, tg_table_name;
 	  		  INSERT INTO log  select nextval('log_index_id_seq'),tg_table_name,id,null, 'Kayıt silindi',  old;	
	   return new;
	end;
 $$;


ALTER FUNCTION public.process_log_after_delete() OWNER TO postgres;

--
-- Name: process_log_after_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_log_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
declare
id int;
	Begin	
	
	if  tg_table_name = 'urunler' then
	id = new.urun_id;
	elseif tg_table_name = 'musteri' then
	id = new.musteri_no;
	end if;
	
	--RAISE NOTICE 'insert işlemi ypıldı index_id %  tbl % usr %', new.index_id, tg_table_name;
 	  		  INSERT INTO log  select nextval('log_index_id_seq'),tg_table_name,id,null, 'Yeni kayıt eklendi',  new;	
	   return new;
	end;
 $$;


ALTER FUNCTION public.process_log_after_insert() OWNER TO postgres;

--
-- Name: process_log_after_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_log_after_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
declare
id int;
	Begin	
	
	if  tg_table_name = 'urunler' then
	id = old.urun_id;
	elseif tg_table_name = 'musteri' then
	id = old.musteri_no;
	end if;
	
	--RAISE NOTICE 'insert işlemi ypıldı index_id %  tbl % usr %', new.index_id, tg_table_name;
 	  		  INSERT INTO log  select nextval('log_index_id_seq'),tg_table_name,id,old, 'Kayıt Güncellendi' ,new;	
	   return new;
	end;
 $$;


ALTER FUNCTION public.process_log_after_update() OWNER TO postgres;

--
-- Name: siparis_getir(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparis_getir(kisi_id integer) RETURNS TABLE(siparis_no integer, tutari double precision, para_birim character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "siparis_id", "tutar", "para_birimi" FROM siparisler
                 WHERE "musteri_id" = kisi_id;
END;
$$;


ALTER FUNCTION public.siparis_getir(kisi_id integer) OWNER TO postgres;

--
-- Name: siparis_toplami(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparis_toplami(siparis_no integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$---Sipariş id si verilen siparişin toplam tutarını gösteririr
-- örnek id 221

declare
	toplam double precision;
 
BEGIN
   SELECT sum(tutar)  into toplam FROM siparis_detay where siparis_id = siparis_no;
   RETURN toplam;
END;
$$;


ALTER FUNCTION public.siparis_toplami(siparis_no integer) OWNER TO postgres;

--
-- Name: siparise_ait_kac_kayit_var(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparise_ait_kac_kayit_var(s_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$--siparis formuna ait kaç kayıt var siparis_detay_tablosunda (siparis_tablosundaki id girilir)
-- örnek id 221

declare
	total integer;
BEGIN
   SELECT count(siparis_id)  into total FROM siparis_detay where siparis_id = s_id;
   RETURN total;
END;
$$;


ALTER FUNCTION public.siparise_ait_kac_kayit_var(s_id integer) OWNER TO postgres;

--
-- Name: stoktan_dus(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stoktan_dus() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
declare
id int;
	Begin		
		-- siparis verilen adet miktarını new.adet ile alıyoruz. 
		--stok_miktari = stok_miktari-new.adet   mevcut stok miktarından sipariş edilen adeti çıkarıyoruz.
 		update urunler set stok_miktari = stok_miktari-new.adet  where urun_id = new.urun_id;
	   return new;
	end;
 $$;


ALTER FUNCTION public.stoktan_dus() OWNER TO postgres;

--
-- Name: areas_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.areas_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.areas_seq OWNER TO postgres;

--
-- Name: cities_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cities_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cities_seq OWNER TO postgres;

--
-- Name: counties_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.counties_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.counties_seq OWNER TO postgres;

--
-- Name: countries_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.countries_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.countries_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: fatura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fatura (
    fatura_id bigint NOT NULL,
    kullanici_id integer,
    musteri_id integer,
    urun_id integer,
    fatura_tarihi timestamp without time zone,
    "ünvanı" character varying(255),
    tutar double precision,
    para_birimi character varying(10),
    kdv double precision,
    vergi_no integer,
    vergi_dairesi character varying(255)
);


ALTER TABLE public.fatura OWNER TO postgres;

--
-- Name: fatura_fatura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fatura_fatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fatura_fatura_id_seq OWNER TO postgres;

--
-- Name: fatura_fatura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fatura_fatura_id_seq OWNED BY public.fatura.fatura_id;


--
-- Name: ilce_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ilce_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ilce_id_seq OWNER TO postgres;

--
-- Name: ilce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilce (
    ilce_id integer DEFAULT nextval('public.ilce_id_seq'::regclass) NOT NULL,
    ilce_kodu character varying(100),
    ilce_adi character varying(100),
    il_kodu character varying(100),
    il_adi character varying(100),
    ulke_kodu character varying(100)
);


ALTER TABLE public.ilce OWNER TO postgres;

--
-- Name: kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategori (
    kategori_id integer NOT NULL,
    kategori_adi character varying(255),
    alt_kategori integer
);


ALTER TABLE public.kategori OWNER TO postgres;

--
-- Name: kategori_kategori_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kategori_kategori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kategori_kategori_id_seq OWNER TO postgres;

--
-- Name: kategori_kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kategori_kategori_id_seq OWNED BY public.kategori.kategori_id;


--
-- Name: kisi_adres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kisi_adres (
    id integer NOT NULL,
    kisi_id integer,
    adres_adi character varying(150),
    adres text
);


ALTER TABLE public.kisi_adres OWNER TO postgres;

--
-- Name: kisiler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kisiler (
    kisi_id integer NOT NULL,
    kisi_adi character varying(255),
    kisi_soyadi character varying(255),
    kisi_tc_no numeric(11,0),
    kisi_cinsiyet character(1),
    kisi_telefon numeric(10,0),
    kisi_mail character varying(100),
    kisi_adres text,
    kisi_ulke character varying(10),
    kisi_il character varying(10),
    kisi_ilce character(255),
    kisi_vergi_dairesi character varying(100),
    kisi_vergi_no numeric(20,0)
);


ALTER TABLE public.kisiler OWNER TO postgres;

--
-- Name: kisiler_kisi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kisiler_kisi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kisiler_kisi_id_seq OWNER TO postgres;

--
-- Name: kisiler_kisi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kisiler_kisi_id_seq OWNED BY public.kisiler.kisi_id;


--
-- Name: kullanici_grubu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanici_grubu (
    group_id bigint NOT NULL,
    group_adi character varying(120)[]
);


ALTER TABLE public.kullanici_grubu OWNER TO postgres;

--
-- Name: kullanici_grobu_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kullanici_grobu_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kullanici_grobu_group_id_seq OWNER TO postgres;

--
-- Name: kullanici_grobu_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kullanici_grobu_group_id_seq OWNED BY public.kullanici_grubu.group_id;


--
-- Name: kullanici_yetkileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanici_yetkileri (
    yetki_id bigint NOT NULL,
    kullanici_id integer,
    group_id integer
);


ALTER TABLE public.kullanici_yetkileri OWNER TO postgres;

--
-- Name: kullanici_yetkileri_yetki_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kullanici_yetkileri_yetki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kullanici_yetkileri_yetki_id_seq OWNER TO postgres;

--
-- Name: kullanici_yetkileri_yetki_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kullanici_yetkileri_yetki_id_seq OWNED BY public.kullanici_yetkileri.yetki_id;


--
-- Name: kullanicilar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanicilar (
    kisi_id integer,
    kullanici_adi character varying(255),
    sifre character varying(255),
    kullanici_group integer
);


ALTER TABLE public.kullanicilar OWNER TO postgres;

--
-- Name: log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log (
    log_id integer NOT NULL,
    tablo character varying(255),
    tablo_id integer,
    eski_data text,
    aciklama text,
    data text
);


ALTER TABLE public.log OWNER TO postgres;

--
-- Name: log_index_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_index_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_index_id_seq OWNER TO postgres;

--
-- Name: log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_log_id_seq OWNER TO postgres;

--
-- Name: log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_log_id_seq OWNED BY public.log.log_id;


--
-- Name: musteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri (
    kisi_id integer,
    musterii_group integer
);


ALTER TABLE public.musteri OWNER TO postgres;

--
-- Name: musteri2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri2 (
    musteri_no bigint NOT NULL,
    musteri_tc numeric(11,0),
    musteri_ad character varying(255),
    musteri_soyad character varying(255),
    musteri_cinsiyet text,
    musteri_telefon numeric,
    musteri_mail text,
    musteri_adres text,
    musteri_sehir name COLLATE pg_catalog."default",
    musteri_ulke character varying(10),
    musteri_ilce character varying(10),
    vergi_dairesi character varying(255),
    vergi_no numeric
);


ALTER TABLE public.musteri2 OWNER TO postgres;

--
-- Name: musteri_adres_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.musteri_adres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.musteri_adres_id_seq OWNER TO postgres;

--
-- Name: musteri_adres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.musteri_adres_id_seq OWNED BY public.kisi_adres.id;


--
-- Name: neighborhoods_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.neighborhoods_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.neighborhoods_seq OWNER TO postgres;

--
-- Name: sehir_index_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sehir_index_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sehir_index_id_seq OWNER TO postgres;

--
-- Name: sehir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sehir (
    sehir_id integer DEFAULT nextval('public.sehir_index_id_seq'::regclass) NOT NULL,
    sehir_kodu character varying(100),
    sehir_adi character varying(100),
    ulke_kodu character varying(100)
);


ALTER TABLE public.sehir OWNER TO postgres;

--
-- Name: siparis_detay; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparis_detay (
    siparis_detay_id bigint NOT NULL,
    siparis_id integer,
    urun_id integer,
    tutar double precision,
    para_birimi character varying(10),
    adet integer
);


ALTER TABLE public.siparis_detay OWNER TO postgres;

--
-- Name: siparis_detay_siparis_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.siparis_detay_siparis_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siparis_detay_siparis_detay_id_seq OWNER TO postgres;

--
-- Name: siparis_detay_siparis_detay_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.siparis_detay_siparis_detay_id_seq OWNED BY public.siparis_detay.siparis_detay_id;


--
-- Name: siparisler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparisler (
    siparis_id integer NOT NULL,
    musteri_id integer,
    kargo_id integer,
    tutar double precision,
    para_birimi character varying(5),
    siparis_tarihi timestamp without time zone,
    kargo_teslim_tarihi timestamp without time zone,
    siparis_durumu integer,
    aciklama text
);


ALTER TABLE public.siparisler OWNER TO postgres;

--
-- Name: siparisler_siparis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.siparisler_siparis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siparisler_siparis_id_seq OWNER TO postgres;

--
-- Name: siparisler_siparis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.siparisler_siparis_id_seq OWNED BY public.siparisler.siparis_id;


--
-- Name: taksit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taksit (
    taksit_id integer NOT NULL,
    urun_id integer,
    adet integer,
    tutar double precision,
    kacinci_taksit integer
);


ALTER TABLE public.taksit OWNER TO postgres;

--
-- Name: taksit_taksit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.taksit_taksit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taksit_taksit_id_seq OWNER TO postgres;

--
-- Name: taksit_taksit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taksit_taksit_id_seq OWNED BY public.taksit.taksit_id;


--
-- Name: ulke_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ulke_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ulke_id_seq OWNER TO postgres;

--
-- Name: ulke; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ulke (
    ulke_id integer DEFAULT nextval('public.ulke_id_seq'::regclass) NOT NULL,
    ulke_kodu character varying(100),
    ulke_adi character varying(100)
);


ALTER TABLE public.ulke OWNER TO postgres;

--
-- Name: urun_resimleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.urun_resimleri (
    urun_resim_id bigint NOT NULL,
    urun_id integer,
    urun_resim character varying(255)
);


ALTER TABLE public.urun_resimleri OWNER TO postgres;

--
-- Name: urun_detay_urun_detay_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.urun_detay_urun_detay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.urun_detay_urun_detay_id_seq OWNER TO postgres;

--
-- Name: urun_detay_urun_detay_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.urun_detay_urun_detay_id_seq OWNED BY public.urun_resimleri.urun_resim_id;


--
-- Name: urunler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.urunler (
    urun_id integer NOT NULL,
    urun_adi character varying,
    urun_fiyati double precision,
    kdv double precision,
    fiyat2 double precision,
    fiyat3 double precision,
    fiyat4 double precision,
    urun_aciklama text,
    stok_miktari integer
);


ALTER TABLE public.urunler OWNER TO postgres;

--
-- Name: urunler_urun_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.urunler_urun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.urunler_urun_id_seq OWNER TO postgres;

--
-- Name: urunler_urun_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.urunler_urun_id_seq OWNED BY public.urunler.urun_id;


--
-- Name: yetkiler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yetkiler (
    yetki_id bigint NOT NULL,
    yetki_adi character varying(255)
);


ALTER TABLE public.yetkiler OWNER TO postgres;

--
-- Name: yetkiler_yetki_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.yetkiler_yetki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.yetkiler_yetki_id_seq OWNER TO postgres;

--
-- Name: yetkiler_yetki_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.yetkiler_yetki_id_seq OWNED BY public.yetkiler.yetki_id;


--
-- Name: fatura fatura_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fatura ALTER COLUMN fatura_id SET DEFAULT nextval('public.fatura_fatura_id_seq'::regclass);


--
-- Name: kategori kategori_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori ALTER COLUMN kategori_id SET DEFAULT nextval('public.kategori_kategori_id_seq'::regclass);


--
-- Name: kisi_adres id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisi_adres ALTER COLUMN id SET DEFAULT nextval('public.musteri_adres_id_seq'::regclass);


--
-- Name: kisiler kisi_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisiler ALTER COLUMN kisi_id SET DEFAULT nextval('public.kisiler_kisi_id_seq'::regclass);


--
-- Name: kullanici_grubu group_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_grubu ALTER COLUMN group_id SET DEFAULT nextval('public.kullanici_grobu_group_id_seq'::regclass);


--
-- Name: kullanici_yetkileri yetki_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_yetkileri ALTER COLUMN yetki_id SET DEFAULT nextval('public.kullanici_yetkileri_yetki_id_seq'::regclass);


--
-- Name: log log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN log_id SET DEFAULT nextval('public.log_log_id_seq'::regclass);


--
-- Name: siparis_detay siparis_detay_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis_detay ALTER COLUMN siparis_detay_id SET DEFAULT nextval('public.siparis_detay_siparis_detay_id_seq'::regclass);


--
-- Name: siparisler siparis_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisler ALTER COLUMN siparis_id SET DEFAULT nextval('public.siparisler_siparis_id_seq'::regclass);


--
-- Name: taksit taksit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taksit ALTER COLUMN taksit_id SET DEFAULT nextval('public.taksit_taksit_id_seq'::regclass);


--
-- Name: urun_resimleri urun_resim_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun_resimleri ALTER COLUMN urun_resim_id SET DEFAULT nextval('public.urun_detay_urun_detay_id_seq'::regclass);


--
-- Name: urunler urun_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urunler ALTER COLUMN urun_id SET DEFAULT nextval('public.urunler_urun_id_seq'::regclass);


--
-- Name: yetkiler yetki_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yetkiler ALTER COLUMN yetki_id SET DEFAULT nextval('public.yetkiler_yetki_id_seq'::regclass);


--
-- Data for Name: fatura; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ilce; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ilce VALUES
	(1, 'TR1101', 'Abana', 'TR37', 'Kastamonu', 'TR'),
	(2, 'TR1102', 'Acıpayam', 'TR20', 'Denizli', 'TR'),
	(3, 'TR1103', 'Adalar', 'TR34', 'İstanbul', 'TR'),
	(4, 'TR1104', 'Seyhan', 'TR01', 'Adana', 'TR'),
	(5, 'TR1105', 'Adıyaman M', 'TR02', 'Adıyaman', 'TR'),
	(6, 'TR1106', 'Adilcevaz', 'TR13', 'Bitlis', 'TR'),
	(7, 'TR1107', 'Afşin', 'TR46', 'Kahramanmaraş', 'TR'),
	(8, 'TR1108', 'Afyonkarah', 'TR03', 'Afyonkarahisar', 'TR'),
	(9, 'TR1109', 'Ağlasun', 'TR15', 'Burdur', 'TR'),
	(10, 'TR1110', 'Ağın', 'TR23', 'Elazığ', 'TR'),
	(11, 'TR1111', 'Ağrı Merke', 'TR04', 'Ağrı', 'TR'),
	(12, 'TR1112', 'Ahlat', 'TR13', 'Bitlis', 'TR'),
	(13, 'TR1113', 'Akçaabat', 'TR61', 'Trabzon', 'TR'),
	(14, 'TR1114', 'Akçadağ', 'TR44', 'Malatya', 'TR'),
	(15, 'TR1115', 'Akçakale', 'TR63', 'Şanlıurfa', 'TR'),
	(16, 'TR1116', 'Akçakoca', 'TR81', 'Düzce', 'TR'),
	(17, 'TR1117', 'Akdağmaden', 'TR66', 'Yozgat', 'TR'),
	(18, 'TR1118', 'Akhisar', 'TR45', 'Manisa', 'TR'),
	(19, 'TR1119', 'Akkuş', 'TR52', 'Ordu', 'TR'),
	(20, 'TR1120', 'Aksaray Me', 'TR68', 'Aksaray', 'TR'),
	(21, 'TR1121', 'Akseki', 'TR07', 'Antalya', 'TR'),
	(22, 'TR1122', 'Akşehir', 'TR42', 'Konya', 'TR'),
	(23, 'TR1123', 'Akyazı', 'TR54', 'Sakarya', 'TR'),
	(24, 'TR1124', 'Alaca', 'TR19', 'Çorum', 'TR'),
	(25, 'TR1125', 'Alaçam', 'TR55', 'Samsun', 'TR'),
	(26, 'TR1126', 'Alanya', 'TR07', 'Antalya', 'TR'),
	(27, 'TR1127', 'Alaşehir', 'TR45', 'Manisa', 'TR'),
	(28, 'TR1128', 'Aliağa', 'TR35', 'İzmir', 'TR'),
	(29, 'TR1129', 'Almus', 'TR60', 'Tokat', 'TR'),
	(30, 'TR1130', 'Altındağ', 'TR06', 'Ankara', 'TR'),
	(31, 'TR1131', 'Altınözü', 'TR31', 'Hatay', 'TR'),
	(32, 'TR1132', 'Altıntaş', 'TR43', 'Kütahya', 'TR'),
	(33, 'TR1133', 'Alucra', 'TR28', 'Giresun', 'TR'),
	(34, 'TR1134', 'Amasya Mer', 'TR05', 'Amasya', 'TR'),
	(35, 'TR1135', 'Anamur', 'TR33', 'Mersin', 'TR'),
	(36, 'TR1136', 'Andırın', 'TR46', 'Kahramanmaraş', 'TR'),
	(37, 'TR1138', 'Antalya Me', 'TR07', 'Antalya', 'TR'),
	(38, 'TR1139', 'Araban', 'TR27', 'Gaziantep', 'TR'),
	(39, 'TR1140', 'Araç', 'TR37', 'Kastamonu', 'TR'),
	(40, 'TR1141', 'Araklı', 'TR61', 'Trabzon', 'TR'),
	(41, 'TR1142', 'Aralık', 'TR76', 'Iğdır', 'TR'),
	(42, 'TR1143', 'Arapgir', 'TR44', 'Malatya', 'TR'),
	(43, 'TR1144', 'Ardahan Me', 'TR75', 'Ardahan', 'TR'),
	(44, 'TR1145', 'Ardanuç', 'TR08', 'Artvin', 'TR'),
	(45, 'TR1146', 'Ardeşen', 'TR53', 'Rize', 'TR'),
	(46, 'TR1147', 'Arhavi', 'TR08', 'Artvin', 'TR'),
	(47, 'TR1148', 'Arguvan', 'TR44', 'Malatya', 'TR'),
	(48, 'TR1149', 'Arpaçay', 'TR36', 'Kars', 'TR'),
	(49, 'TR1150', 'Arsin', 'TR61', 'Trabzon', 'TR'),
	(50, 'TR1151', 'Artova', 'TR60', 'Tokat', 'TR'),
	(51, 'TR1152', 'Artvin Mer', 'TR08', 'Artvin', 'TR'),
	(52, 'TR1153', 'Aşkale', 'TR25', 'Erzurum', 'TR'),
	(53, 'TR1154', 'Atabey', 'TR32', 'Isparta', 'TR'),
	(54, 'TR1155', 'Avanos', 'TR50', 'Nevşehir', 'TR'),
	(55, 'TR1156', 'Ayancık', 'TR57', 'Sinop', 'TR'),
	(56, 'TR1157', 'Ayaş', 'TR06', 'Ankara', 'TR'),
	(57, 'TR1158', 'Aybastı', 'TR52', 'Ordu', 'TR'),
	(58, 'TR1159', 'Aydın Merk', 'TR09', 'Aydın', 'TR'),
	(59, 'TR1160', 'Ayvacık / ', 'TR17', 'Çanakkale', 'TR'),
	(60, 'TR1161', 'Ayvalık', 'TR10', 'Balıkesir', 'TR'),
	(61, 'TR1162', 'Azdavay', 'TR37', 'Kastamonu', 'TR'),
	(62, 'TR1163', 'Babaeski', 'TR39', 'Kırklareli', 'TR'),
	(63, 'TR1164', 'Bafra', 'TR55', 'Samsun', 'TR'),
	(64, 'TR1165', 'Bahçe', 'TR80', 'Osmaniye', 'TR'),
	(65, 'TR1166', 'Bakırköy', 'TR34', 'İstanbul', 'TR'),
	(66, 'TR1167', 'Bala', 'TR06', 'Ankara', 'TR'),
	(67, 'TR1168', 'Balıkesir ', 'TR10', 'Balıkesir', 'TR'),
	(68, 'TR1169', 'Balya', 'TR10', 'Balıkesir', 'TR'),
	(69, 'TR1170', 'Banaz', 'TR64', 'Uşak', 'TR'),
	(70, 'TR1171', 'Bandırma', 'TR10', 'Balıkesir', 'TR'),
	(71, 'TR1172', 'Bartın Mer', 'TR74', 'Bartın', 'TR'),
	(72, 'TR1173', 'Baskil', 'TR23', 'Elazığ', 'TR'),
	(73, 'TR1174', 'Batman Mer', 'TR72', 'Batman', 'TR'),
	(74, 'TR1175', 'Başkale', 'TR65', 'Van', 'TR'),
	(75, 'TR1176', 'Bayburt Me', 'TR69', 'Bayburt', 'TR'),
	(76, 'TR1177', 'Bayat / Ço', 'TR19', 'Çorum', 'TR'),
	(77, 'TR1178', 'Bayındır', 'TR35', 'İzmir', 'TR'),
	(78, 'TR1179', 'Baykan', 'TR56', 'Siirt', 'TR'),
	(79, 'TR1180', 'Bayramiç', 'TR17', 'Çanakkale', 'TR'),
	(80, 'TR1181', 'Bergama', 'TR35', 'İzmir', 'TR'),
	(81, 'TR1182', 'Besni', 'TR02', 'Adıyaman', 'TR'),
	(82, 'TR1183', 'Beşiktaş', 'TR34', 'İstanbul', 'TR'),
	(83, 'TR1184', 'Beşiri', 'TR72', 'Batman', 'TR'),
	(84, 'TR1185', 'Beykoz', 'TR34', 'İstanbul', 'TR'),
	(85, 'TR1186', 'Beyoğlu', 'TR34', 'İstanbul', 'TR'),
	(86, 'TR1187', 'Beypazarı', 'TR06', 'Ankara', 'TR'),
	(87, 'TR1188', 'Beyşehir', 'TR42', 'Konya', 'TR'),
	(88, 'TR1189', 'Beytüşşeba', 'TR73', 'Şırnak', 'TR'),
	(89, 'TR1190', 'Biga', 'TR17', 'Çanakkale', 'TR'),
	(90, 'TR1191', 'Bigadiç', 'TR10', 'Balıkesir', 'TR'),
	(91, 'TR1192', 'Bilecik Me', 'TR11', 'Bilecik', 'TR'),
	(92, 'TR1193', 'Bingöl Mer', 'TR12', 'Bingöl', 'TR'),
	(93, 'TR1194', 'Birecik', 'TR63', 'Şanlıurfa', 'TR'),
	(94, 'TR1195', 'Bismil', 'TR21', 'Diyarbakır', 'TR'),
	(95, 'TR1196', 'Bitlis Mer', 'TR13', 'Bitlis', 'TR'),
	(96, 'TR1197', 'Bodrum', 'TR48', 'Muğla', 'TR'),
	(97, 'TR1198', 'Boğazlıyan', 'TR66', 'Yozgat', 'TR'),
	(98, 'TR1199', 'Bolu Merke', 'TR14', 'Bolu', 'TR'),
	(99, 'TR1200', 'Bolvadin', 'TR03', 'Afyonkarahisar', 'TR'),
	(100, 'TR1201', 'Bor', 'TR51', 'Niğde', 'TR'),
	(101, 'TR1202', 'Borçka', 'TR08', 'Artvin', 'TR'),
	(102, 'TR1203', 'Bornova', 'TR35', 'İzmir', 'TR'),
	(103, 'TR1204', 'Boyabat', 'TR57', 'Sinop', 'TR'),
	(104, 'TR1205', 'Bozcaada', 'TR17', 'Çanakkale', 'TR'),
	(105, 'TR1206', 'Bozdoğan', 'TR09', 'Aydın', 'TR'),
	(106, 'TR1207', 'Bozkır', 'TR42', 'Konya', 'TR'),
	(107, 'TR1208', 'Bozkurt / ', 'TR37', 'Kastamonu', 'TR'),
	(108, 'TR1209', 'Bozova', 'TR63', 'Şanlıurfa', 'TR'),
	(109, 'TR1210', 'Bozüyük', 'TR11', 'Bilecik', 'TR'),
	(110, 'TR1211', 'Bucak', 'TR15', 'Burdur', 'TR'),
	(111, 'TR1212', 'Bulancak', 'TR28', 'Giresun', 'TR'),
	(112, 'TR1213', 'Bulanık', 'TR49', 'Muş', 'TR'),
	(113, 'TR1214', 'Buldan', 'TR20', 'Denizli', 'TR'),
	(114, 'TR1215', 'Burdur Mer', 'TR15', 'Burdur', 'TR'),
	(115, 'TR1216', 'Burhaniye', 'TR10', 'Balıkesir', 'TR'),
	(116, 'TR1218', 'Bünyan', 'TR38', 'Kayseri', 'TR'),
	(117, 'TR1219', 'Ceyhan', 'TR01', 'Adana', 'TR'),
	(118, 'TR1220', 'Ceylanpına', 'TR63', 'Şanlıurfa', 'TR'),
	(119, 'TR1221', 'Cide', 'TR37', 'Kastamonu', 'TR'),
	(120, 'TR1222', 'Cihanbeyli', 'TR42', 'Konya', 'TR'),
	(121, 'TR1223', 'Cizre', 'TR73', 'Şırnak', 'TR'),
	(122, 'TR1224', 'Çal', 'TR20', 'Denizli', 'TR'),
	(123, 'TR1225', 'Çamardı', 'TR51', 'Niğde', 'TR'),
	(124, 'TR1226', 'Çameli', 'TR20', 'Denizli', 'TR'),
	(125, 'TR1227', 'Çamlıdere', 'TR06', 'Ankara', 'TR'),
	(126, 'TR1228', 'Çamlıhemşi', 'TR53', 'Rize', 'TR'),
	(127, 'TR1229', 'Çan', 'TR17', 'Çanakkale', 'TR'),
	(128, 'TR1230', 'Çanakkale ', 'TR17', 'Çanakkale', 'TR'),
	(129, 'TR1231', 'Çankaya', 'TR06', 'Ankara', 'TR'),
	(130, 'TR1232', 'Çankırı Me', 'TR18', 'Çankırı', 'TR'),
	(131, 'TR1233', 'Çardak', 'TR20', 'Denizli', 'TR'),
	(132, 'TR1234', 'Çarşamba', 'TR55', 'Samsun', 'TR'),
	(133, 'TR1235', 'Çat', 'TR25', 'Erzurum', 'TR'),
	(134, 'TR1236', 'Çatak', 'TR65', 'Van', 'TR'),
	(135, 'TR1237', 'Çatalca', 'TR34', 'İstanbul', 'TR'),
	(136, 'TR1238', 'Çatalzeyti', 'TR37', 'Kastamonu', 'TR'),
	(137, 'TR1239', 'Çay', 'TR03', 'Afyonkarahisar', 'TR'),
	(138, 'TR1240', 'Çaycuma', 'TR67', 'Zonguldak', 'TR'),
	(139, 'TR1241', 'Çayeli', 'TR53', 'Rize', 'TR'),
	(140, 'TR1242', 'Çayıralan', 'TR66', 'Yozgat', 'TR'),
	(141, 'TR1243', 'Çayırlı', 'TR24', 'Erzincan', 'TR'),
	(142, 'TR1244', 'Çaykara', 'TR61', 'Trabzon', 'TR'),
	(143, 'TR1245', 'Çekerek', 'TR66', 'Yozgat', 'TR'),
	(144, 'TR1246', 'Çelikhan', 'TR02', 'Adıyaman', 'TR'),
	(145, 'TR1247', 'Çemişgezek', 'TR62', 'Tunceli', 'TR'),
	(146, 'TR1248', 'Çerkeş', 'TR18', 'Çankırı', 'TR'),
	(147, 'TR1249', 'Çermik', 'TR21', 'Diyarbakır', 'TR'),
	(148, 'TR1250', 'Çerkezköy', 'TR59', 'Tekirdağ', 'TR'),
	(149, 'TR1251', 'Çeşme', 'TR35', 'İzmir', 'TR'),
	(150, 'TR1252', 'Çıldır', 'TR75', 'Ardahan', 'TR'),
	(151, 'TR1253', 'Çınar', 'TR21', 'Diyarbakır', 'TR'),
	(152, 'TR1254', 'Çiçekdağı', 'TR40', 'Kırşehir', 'TR'),
	(153, 'TR1255', 'Çifteler', 'TR26', 'Eskişehir', 'TR'),
	(154, 'TR1256', 'Çine', 'TR09', 'Aydın', 'TR'),
	(155, 'TR1257', 'Çivril', 'TR20', 'Denizli', 'TR'),
	(156, 'TR1258', 'Çorlu', 'TR59', 'Tekirdağ', 'TR'),
	(157, 'TR1259', 'Çorum Merk', 'TR19', 'Çorum', 'TR'),
	(158, 'TR1260', 'Çubuk', 'TR06', 'Ankara', 'TR'),
	(159, 'TR1261', 'Çukurca', 'TR30', 'Hakkari', 'TR'),
	(160, 'TR1262', 'Çumra', 'TR42', 'Konya', 'TR'),
	(161, 'TR1263', 'Çüngüş', 'TR21', 'Diyarbakır', 'TR'),
	(162, 'TR1264', 'Daday', 'TR37', 'Kastamonu', 'TR'),
	(163, 'TR1265', 'Darende', 'TR44', 'Malatya', 'TR'),
	(164, 'TR1266', 'Datça', 'TR48', 'Muğla', 'TR'),
	(165, 'TR1267', 'Dazkırı', 'TR03', 'Afyonkarahisar', 'TR'),
	(166, 'TR1268', 'Delice', 'TR71', 'Kırıkkale', 'TR'),
	(167, 'TR1269', 'Demirci', 'TR45', 'Manisa', 'TR'),
	(168, 'TR1270', 'Demirköy', 'TR39', 'Kırklareli', 'TR'),
	(169, 'TR1271', 'Denizli Me', 'TR20', 'Denizli', 'TR'),
	(170, 'TR1272', 'Dereli', 'TR28', 'Giresun', 'TR'),
	(171, 'TR1273', 'Derik', 'TR47', 'Mardin', 'TR'),
	(172, 'TR1274', 'Derinkuyu', 'TR50', 'Nevşehir', 'TR'),
	(173, 'TR1275', 'Develi', 'TR38', 'Kayseri', 'TR'),
	(174, 'TR1276', 'Devrek', 'TR67', 'Zonguldak', 'TR'),
	(175, 'TR1277', 'Devrekani', 'TR37', 'Kastamonu', 'TR'),
	(176, 'TR1278', 'Dicle', 'TR21', 'Diyarbakır', 'TR'),
	(177, 'TR1279', 'Digor', 'TR36', 'Kars', 'TR'),
	(178, 'TR1280', 'Dikili', 'TR35', 'İzmir', 'TR'),
	(179, 'TR1281', 'Dinar', 'TR03', 'Afyonkarahisar', 'TR'),
	(180, 'TR1282', 'Divriği', 'TR58', 'Sivas', 'TR'),
	(181, 'TR1283', 'Diyadin', 'TR04', 'Ağrı', 'TR'),
	(182, 'TR1284', 'Diyarbakır', 'TR21', 'Diyarbakır', 'TR'),
	(183, 'TR1285', 'Doğanhisar', 'TR42', 'Konya', 'TR'),
	(184, 'TR1286', 'Doğanşehir', 'TR44', 'Malatya', 'TR'),
	(185, 'TR1287', 'Doğubayazı', 'TR04', 'Ağrı', 'TR'),
	(186, 'TR1288', 'Domaniç', 'TR43', 'Kütahya', 'TR'),
	(187, 'TR1289', 'Dörtyol', 'TR31', 'Hatay', 'TR'),
	(188, 'TR1290', 'Durağan', 'TR57', 'Sinop', 'TR'),
	(189, 'TR1291', 'Dursunbey', 'TR10', 'Balıkesir', 'TR'),
	(190, 'TR1292', 'Düzce Merk', 'TR81', 'Düzce', 'TR'),
	(191, 'TR1293', 'Eceabat', 'TR17', 'Çanakkale', 'TR'),
	(192, 'TR1294', 'Edremit / ', 'TR10', 'Balıkesir', 'TR'),
	(193, 'TR1295', 'Edirne Mer', 'TR22', 'Edirne', 'TR'),
	(194, 'TR1296', 'Eflani', 'TR78', 'Karabük', 'TR'),
	(195, 'TR1297', 'Eğirdir', 'TR32', 'Isparta', 'TR'),
	(196, 'TR1298', 'Elazığ Mer', 'TR23', 'Elazığ', 'TR'),
	(197, 'TR1299', 'Elbistan', 'TR46', 'Kahramanmaraş', 'TR'),
	(198, 'TR1300', 'Eldivan', 'TR18', 'Çankırı', 'TR'),
	(199, 'TR1301', 'Eleşkirt', 'TR04', 'Ağrı', 'TR'),
	(200, 'TR1302', 'Elmadağ', 'TR06', 'Ankara', 'TR'),
	(201, 'TR1303', 'Elmalı', 'TR07', 'Antalya', 'TR'),
	(202, 'TR1304', 'Emet', 'TR43', 'Kütahya', 'TR'),
	(203, 'TR1305', 'Eminönü', 'TR34', 'İstanbul', 'TR'),
	(204, 'TR1306', 'Emirdağ', 'TR03', 'Afyonkarahisar', 'TR'),
	(205, 'TR1307', 'Enez', 'TR22', 'Edirne', 'TR'),
	(206, 'TR1308', 'Erbaa', 'TR60', 'Tokat', 'TR'),
	(207, 'TR1309', 'Erciş', 'TR65', 'Van', 'TR'),
	(208, 'TR1310', 'Erdek', 'TR10', 'Balıkesir', 'TR'),
	(209, 'TR1311', 'Erdemli', 'TR33', 'Mersin', 'TR'),
	(210, 'TR1312', 'Ereğli / K', 'TR42', 'Konya', 'TR'),
	(211, 'TR1313', 'Ereğli / Z', 'TR67', 'Zonguldak', 'TR'),
	(212, 'TR1314', 'Erfelek', 'TR57', 'Sinop', 'TR'),
	(213, 'TR1315', 'Ergani', 'TR21', 'Diyarbakır', 'TR'),
	(214, 'TR1316', 'Ermenek', 'TR70', 'Karaman', 'TR'),
	(215, 'TR1317', 'Eruh', 'TR56', 'Siirt', 'TR'),
	(216, 'TR1318', 'Erzincan M', 'TR24', 'Erzincan', 'TR'),
	(217, 'TR1319', 'Erzurum Me', 'TR25', 'Erzurum', 'TR'),
	(218, 'TR1320', 'Espiye', 'TR28', 'Giresun', 'TR'),
	(219, 'TR1321', 'Eskipazar', 'TR78', 'Karabük', 'TR'),
	(220, 'TR1322', 'Eskişehir ', 'TR26', 'Eskişehir', 'TR'),
	(221, 'TR1323', 'Eşme', 'TR64', 'Uşak', 'TR'),
	(222, 'TR1324', 'Eynesil', 'TR28', 'Giresun', 'TR'),
	(223, 'TR1325', 'Eyüp', 'TR34', 'İstanbul', 'TR'),
	(224, 'TR1326', 'Ezine', 'TR17', 'Çanakkale', 'TR'),
	(225, 'TR1327', 'Fatih', 'TR34', 'İstanbul', 'TR'),
	(226, 'TR1328', 'Fatsa', 'TR52', 'Ordu', 'TR'),
	(227, 'TR1329', 'Feke', 'TR01', 'Adana', 'TR'),
	(228, 'TR1330', 'Felahiye', 'TR38', 'Kayseri', 'TR'),
	(229, 'TR1331', 'Fethiye', 'TR48', 'Muğla', 'TR'),
	(230, 'TR1332', 'Fındıklı', 'TR53', 'Rize', 'TR'),
	(231, 'TR1333', 'Finike', 'TR07', 'Antalya', 'TR'),
	(232, 'TR1334', 'Foça', 'TR35', 'İzmir', 'TR'),
	(233, 'TR1336', 'Gaziosmanp', 'TR34', 'İstanbul', 'TR'),
	(234, 'TR1337', 'Gazipaşa', 'TR07', 'Antalya', 'TR'),
	(235, 'TR1338', 'Gebze', 'TR41', 'Kocaeli', 'TR'),
	(236, 'TR1339', 'Gediz', 'TR43', 'Kütahya', 'TR'),
	(237, 'TR1340', 'Gelibolu', 'TR17', 'Çanakkale', 'TR'),
	(238, 'TR1341', 'Gelendost', 'TR32', 'Isparta', 'TR'),
	(239, 'TR1342', 'Gemerek', 'TR58', 'Sivas', 'TR'),
	(240, 'TR1343', 'Gemlik', 'TR16', 'Bursa', 'TR'),
	(241, 'TR1344', 'Genç', 'TR12', 'Bingöl', 'TR'),
	(242, 'TR1345', 'Gercüş', 'TR72', 'Batman', 'TR'),
	(243, 'TR1346', 'Gerede', 'TR14', 'Bolu', 'TR'),
	(244, 'TR1347', 'Gerger', 'TR02', 'Adıyaman', 'TR'),
	(245, 'TR1348', 'Germencik', 'TR09', 'Aydın', 'TR'),
	(246, 'TR1349', 'Gerze', 'TR57', 'Sinop', 'TR'),
	(247, 'TR1350', 'Gevaş', 'TR65', 'Van', 'TR'),
	(248, 'TR1351', 'Geyve', 'TR54', 'Sakarya', 'TR'),
	(249, 'TR1352', 'Giresun Me', 'TR28', 'Giresun', 'TR'),
	(250, 'TR1353', 'Göksun', 'TR46', 'Kahramanmaraş', 'TR');
INSERT INTO public.ilce VALUES
	(251, 'TR1354', 'Gölbaşı / ', 'TR02', 'Adıyaman', 'TR'),
	(252, 'TR1355', 'Gölcük', 'TR41', 'Kocaeli', 'TR'),
	(253, 'TR1356', 'Göle', 'TR75', 'Ardahan', 'TR'),
	(254, 'TR1357', 'Gölhisar', 'TR15', 'Burdur', 'TR'),
	(255, 'TR1358', 'Gölköy', 'TR52', 'Ordu', 'TR'),
	(256, 'TR1359', 'Gölpazarı', 'TR11', 'Bilecik', 'TR'),
	(257, 'TR1360', 'Gönen / Ba', 'TR10', 'Balıkesir', 'TR'),
	(258, 'TR1361', 'Görele', 'TR28', 'Giresun', 'TR'),
	(259, 'TR1362', 'Gördes', 'TR45', 'Manisa', 'TR'),
	(260, 'TR1363', 'Göynücek', 'TR05', 'Amasya', 'TR'),
	(261, 'TR1364', 'Göynük', 'TR14', 'Bolu', 'TR'),
	(262, 'TR1365', 'Güdül', 'TR06', 'Ankara', 'TR'),
	(263, 'TR1366', 'Gülnar', 'TR33', 'Mersin', 'TR'),
	(264, 'TR1367', 'Gülşehir', 'TR50', 'Nevşehir', 'TR'),
	(265, 'TR1368', 'Gümüşhacık', 'TR05', 'Amasya', 'TR'),
	(266, 'TR1369', 'Gümüşhane ', 'TR29', 'Gümüşhane', 'TR'),
	(267, 'TR1370', 'Gündoğmuş', 'TR07', 'Antalya', 'TR'),
	(268, 'TR1371', 'Güney', 'TR20', 'Denizli', 'TR'),
	(269, 'TR1372', 'Gürpınar', 'TR65', 'Van', 'TR'),
	(270, 'TR1373', 'Gürün', 'TR58', 'Sivas', 'TR'),
	(271, 'TR1374', 'Hacıbektaş', 'TR50', 'Nevşehir', 'TR'),
	(272, 'TR1375', 'Hadim', 'TR42', 'Konya', 'TR'),
	(273, 'TR1376', 'Hafik', 'TR58', 'Sivas', 'TR'),
	(274, 'TR1377', 'Hakkari Me', 'TR30', 'Hakkari', 'TR'),
	(275, 'TR1378', 'Halfeti', 'TR63', 'Şanlıurfa', 'TR'),
	(276, 'TR1379', 'Hamur', 'TR04', 'Ağrı', 'TR'),
	(277, 'TR1380', 'Hanak', 'TR75', 'Ardahan', 'TR'),
	(278, 'TR1381', 'Hani', 'TR21', 'Diyarbakır', 'TR'),
	(279, 'TR1382', 'Hassa', 'TR31', 'Hatay', 'TR'),
	(280, 'TR1383', 'Hatay Merk', 'TR31', 'Hatay', 'TR'),
	(281, 'TR1384', 'Havran', 'TR10', 'Balıkesir', 'TR'),
	(282, 'TR1385', 'Havsa', 'TR22', 'Edirne', 'TR'),
	(283, 'TR1386', 'Havza', 'TR55', 'Samsun', 'TR'),
	(284, 'TR1387', 'Haymana', 'TR06', 'Ankara', 'TR'),
	(285, 'TR1388', 'Hayrabolu', 'TR59', 'Tekirdağ', 'TR'),
	(286, 'TR1389', 'Hazro', 'TR21', 'Diyarbakır', 'TR'),
	(287, 'TR1390', 'Hekimhan', 'TR44', 'Malatya', 'TR'),
	(288, 'TR1391', 'Hendek', 'TR54', 'Sakarya', 'TR'),
	(289, 'TR1392', 'Hınıs', 'TR25', 'Erzurum', 'TR'),
	(290, 'TR1393', 'Hilvan', 'TR63', 'Şanlıurfa', 'TR'),
	(291, 'TR1394', 'Hizan', 'TR13', 'Bitlis', 'TR'),
	(292, 'TR1395', 'Hopa', 'TR08', 'Artvin', 'TR'),
	(293, 'TR1396', 'Horasan', 'TR25', 'Erzurum', 'TR'),
	(294, 'TR1397', 'Hozat', 'TR62', 'Tunceli', 'TR'),
	(295, 'TR1398', 'Iğdır Merk', 'TR76', 'Iğdır', 'TR'),
	(296, 'TR1399', 'Ilgaz', 'TR18', 'Çankırı', 'TR'),
	(297, 'TR1400', 'Ilgın', 'TR42', 'Konya', 'TR'),
	(298, 'TR1401', 'Isparta Me', 'TR32', 'Isparta', 'TR'),
	(299, 'TR1402', 'Mersin Mer', 'TR33', 'Mersin', 'TR'),
	(300, 'TR1403', 'İdil', 'TR73', 'Şırnak', 'TR'),
	(301, 'TR1404', 'İhsaniye', 'TR03', 'Afyonkarahisar', 'TR'),
	(302, 'TR1405', 'İkizdere', 'TR53', 'Rize', 'TR'),
	(303, 'TR1406', 'İliç', 'TR24', 'Erzincan', 'TR'),
	(304, 'TR1407', 'İmranlı', 'TR58', 'Sivas', 'TR'),
	(305, 'TR1408', 'Gökçeada', 'TR17', 'Çanakkale', 'TR'),
	(306, 'TR1409', 'İncesu', 'TR38', 'Kayseri', 'TR'),
	(307, 'TR1410', 'İnebolu', 'TR37', 'Kastamonu', 'TR'),
	(308, 'TR1411', 'İnegöl', 'TR16', 'Bursa', 'TR'),
	(309, 'TR1412', 'İpsala', 'TR22', 'Edirne', 'TR'),
	(310, 'TR1413', 'İskenderun', 'TR31', 'Hatay', 'TR'),
	(311, 'TR1414', 'İskilip', 'TR19', 'Çorum', 'TR'),
	(312, 'TR1415', 'İslahiye', 'TR27', 'Gaziantep', 'TR'),
	(313, 'TR1416', 'İspir', 'TR25', 'Erzurum', 'TR'),
	(314, 'TR1418', 'İvrindi', 'TR10', 'Balıkesir', 'TR'),
	(315, 'TR1420', 'İznik', 'TR16', 'Bursa', 'TR'),
	(316, 'TR1421', 'Kadıköy', 'TR34', 'İstanbul', 'TR'),
	(317, 'TR1422', 'Kadınhanı', 'TR42', 'Konya', 'TR'),
	(318, 'TR1423', 'Kadirli', 'TR80', 'Osmaniye', 'TR'),
	(319, 'TR1424', 'Kağızman', 'TR36', 'Kars', 'TR'),
	(320, 'TR1425', 'Kahta', 'TR02', 'Adıyaman', 'TR'),
	(321, 'TR1426', 'Kale / Den', 'TR20', 'Denizli', 'TR'),
	(322, 'TR1427', 'Kalecik', 'TR06', 'Ankara', 'TR'),
	(323, 'TR1428', 'Kalkandere', 'TR53', 'Rize', 'TR'),
	(324, 'TR1429', 'Kaman', 'TR40', 'Kırşehir', 'TR'),
	(325, 'TR1430', 'Kandıra', 'TR41', 'Kocaeli', 'TR'),
	(326, 'TR1431', 'Kangal', 'TR58', 'Sivas', 'TR'),
	(327, 'TR1432', 'Karaburun', 'TR35', 'İzmir', 'TR'),
	(328, 'TR1433', 'Karabük Me', 'TR78', 'Karabük', 'TR'),
	(329, 'TR1434', 'Karacabey', 'TR16', 'Bursa', 'TR'),
	(330, 'TR1435', 'Karacasu', 'TR09', 'Aydın', 'TR'),
	(331, 'TR1436', 'Karahallı', 'TR64', 'Uşak', 'TR'),
	(332, 'TR1437', 'Karaisalı', 'TR01', 'Adana', 'TR'),
	(333, 'TR1438', 'Karakoçan', 'TR23', 'Elazığ', 'TR'),
	(334, 'TR1439', 'Karaman Me', 'TR70', 'Karaman', 'TR'),
	(335, 'TR1440', 'Karamürsel', 'TR41', 'Kocaeli', 'TR'),
	(336, 'TR1441', 'Karapınar', 'TR42', 'Konya', 'TR'),
	(337, 'TR1442', 'Karasu', 'TR54', 'Sakarya', 'TR'),
	(338, 'TR1443', 'Karataş', 'TR01', 'Adana', 'TR'),
	(339, 'TR1444', 'Karayazı', 'TR25', 'Erzurum', 'TR'),
	(340, 'TR1445', 'Kargı', 'TR19', 'Çorum', 'TR'),
	(341, 'TR1446', 'Karlıova', 'TR12', 'Bingöl', 'TR'),
	(342, 'TR1447', 'Kars Merke', 'TR36', 'Kars', 'TR'),
	(343, 'TR1448', 'Karşıyaka', 'TR35', 'İzmir', 'TR'),
	(344, 'TR1449', 'Kartal', 'TR34', 'İstanbul', 'TR'),
	(345, 'TR1450', 'Kastamonu ', 'TR37', 'Kastamonu', 'TR'),
	(346, 'TR1451', 'Kaş', 'TR07', 'Antalya', 'TR'),
	(347, 'TR1452', 'Kavak', 'TR55', 'Samsun', 'TR'),
	(348, 'TR1453', 'Kaynarca', 'TR54', 'Sakarya', 'TR'),
	(349, 'TR1455', 'Keban', 'TR23', 'Elazığ', 'TR'),
	(350, 'TR1456', 'Keçiborlu', 'TR32', 'Isparta', 'TR'),
	(351, 'TR1457', 'Keles', 'TR16', 'Bursa', 'TR'),
	(352, 'TR1458', 'Kelkit', 'TR29', 'Gümüşhane', 'TR'),
	(353, 'TR1459', 'Kemah', 'TR24', 'Erzincan', 'TR'),
	(354, 'TR1460', 'Kemaliye', 'TR24', 'Erzincan', 'TR'),
	(355, 'TR1461', 'Kemalpaşa', 'TR35', 'İzmir', 'TR'),
	(356, 'TR1462', 'Kepsut', 'TR10', 'Balıkesir', 'TR'),
	(357, 'TR1463', 'Keskin', 'TR71', 'Kırıkkale', 'TR'),
	(358, 'TR1464', 'Keşan', 'TR22', 'Edirne', 'TR'),
	(359, 'TR1465', 'Keşap', 'TR28', 'Giresun', 'TR'),
	(360, 'TR1466', 'Kıbrıscık', 'TR14', 'Bolu', 'TR'),
	(361, 'TR1467', 'Kınık', 'TR35', 'İzmir', 'TR'),
	(362, 'TR1468', 'Kırıkhan', 'TR31', 'Hatay', 'TR'),
	(363, 'TR1469', 'Kırıkkale ', 'TR71', 'Kırıkkale', 'TR'),
	(364, 'TR1470', 'Kırkağaç', 'TR45', 'Manisa', 'TR'),
	(365, 'TR1471', 'Kırklareli', 'TR39', 'Kırklareli', 'TR'),
	(366, 'TR1472', 'Kırşehir M', 'TR40', 'Kırşehir', 'TR'),
	(367, 'TR1473', 'Kızılcaham', 'TR06', 'Ankara', 'TR'),
	(368, 'TR1474', 'Kızıltepe', 'TR47', 'Mardin', 'TR'),
	(369, 'TR1475', 'Kiğı', 'TR12', 'Bingöl', 'TR'),
	(370, 'TR1476', 'Kilis Merk', 'TR79', 'Kilis', 'TR'),
	(371, 'TR1477', 'Kiraz', 'TR35', 'İzmir', 'TR'),
	(372, 'TR1478', 'Kocaeli Me', 'TR41', 'Kocaeli', 'TR'),
	(373, 'TR1479', 'Koçarlı', 'TR09', 'Aydın', 'TR'),
	(374, 'TR1480', 'Kofçaz', 'TR39', 'Kırklareli', 'TR'),
	(375, 'TR1482', 'Korgan', 'TR52', 'Ordu', 'TR'),
	(376, 'TR1483', 'Korkuteli', 'TR07', 'Antalya', 'TR'),
	(377, 'TR1484', 'Koyulhisar', 'TR58', 'Sivas', 'TR'),
	(378, 'TR1485', 'Kozaklı', 'TR50', 'Nevşehir', 'TR'),
	(379, 'TR1486', 'Kozan', 'TR01', 'Adana', 'TR'),
	(380, 'TR1487', 'Kozluk', 'TR72', 'Batman', 'TR'),
	(381, 'TR1488', 'Köyceğiz', 'TR48', 'Muğla', 'TR'),
	(382, 'TR1489', 'Kula', 'TR45', 'Manisa', 'TR'),
	(383, 'TR1490', 'Kulp', 'TR21', 'Diyarbakır', 'TR'),
	(384, 'TR1491', 'Kulu', 'TR42', 'Konya', 'TR'),
	(385, 'TR1492', 'Kumluca', 'TR07', 'Antalya', 'TR'),
	(386, 'TR1493', 'Kumru', 'TR52', 'Ordu', 'TR'),
	(387, 'TR1494', 'Kurşunlu', 'TR18', 'Çankırı', 'TR'),
	(388, 'TR1495', 'Kurtalan', 'TR56', 'Siirt', 'TR'),
	(389, 'TR1496', 'Kurucaşile', 'TR74', 'Bartın', 'TR'),
	(390, 'TR1497', 'Kuşadası', 'TR09', 'Aydın', 'TR'),
	(391, 'TR1498', 'Kuyucak', 'TR09', 'Aydın', 'TR'),
	(392, 'TR1499', 'Küre', 'TR37', 'Kastamonu', 'TR'),
	(393, 'TR1500', 'Kütahya Me', 'TR43', 'Kütahya', 'TR'),
	(394, 'TR1501', 'Ladik', 'TR55', 'Samsun', 'TR'),
	(395, 'TR1502', 'Lalapaşa', 'TR22', 'Edirne', 'TR'),
	(396, 'TR1503', 'Lapseki', 'TR17', 'Çanakkale', 'TR'),
	(397, 'TR1504', 'Lice', 'TR21', 'Diyarbakır', 'TR'),
	(398, 'TR1505', 'Lüleburgaz', 'TR39', 'Kırklareli', 'TR'),
	(399, 'TR1506', 'Maden', 'TR23', 'Elazığ', 'TR'),
	(400, 'TR1507', 'Maçka', 'TR61', 'Trabzon', 'TR'),
	(401, 'TR1508', 'Mahmudiye', 'TR26', 'Eskişehir', 'TR'),
	(402, 'TR1509', 'Malatya Me', 'TR44', 'Malatya', 'TR'),
	(403, 'TR1510', 'Malazgirt', 'TR49', 'Muş', 'TR'),
	(404, 'TR1511', 'Malkara', 'TR59', 'Tekirdağ', 'TR'),
	(405, 'TR1512', 'Manavgat', 'TR07', 'Antalya', 'TR'),
	(406, 'TR1513', 'Manisa Mer', 'TR45', 'Manisa', 'TR'),
	(407, 'TR1514', 'Manyas', 'TR10', 'Balıkesir', 'TR'),
	(408, 'TR1515', 'Kahramanma', 'TR46', 'Kahramanmaraş', 'TR'),
	(409, 'TR1516', 'Mardin Mer', 'TR47', 'Mardin', 'TR'),
	(410, 'TR1517', 'Marmaris', 'TR48', 'Muğla', 'TR'),
	(411, 'TR1518', 'Mazgirt', 'TR62', 'Tunceli', 'TR'),
	(412, 'TR1519', 'Mazıdağı', 'TR47', 'Mardin', 'TR'),
	(413, 'TR1520', 'Mecitözü', 'TR19', 'Çorum', 'TR'),
	(414, 'TR1521', 'Menemen', 'TR35', 'İzmir', 'TR'),
	(415, 'TR1522', 'Mengen', 'TR14', 'Bolu', 'TR'),
	(416, 'TR1523', 'Meriç', 'TR22', 'Edirne', 'TR'),
	(417, 'TR1524', 'Merzifon', 'TR05', 'Amasya', 'TR'),
	(418, 'TR1525', 'Mesudiye', 'TR52', 'Ordu', 'TR'),
	(419, 'TR1526', 'Midyat', 'TR47', 'Mardin', 'TR'),
	(420, 'TR1527', 'Mihalıççık', 'TR26', 'Eskişehir', 'TR'),
	(421, 'TR1528', 'Milas', 'TR48', 'Muğla', 'TR'),
	(422, 'TR1529', 'Mucur', 'TR40', 'Kırşehir', 'TR'),
	(423, 'TR1530', 'Mudanya', 'TR16', 'Bursa', 'TR'),
	(424, 'TR1531', 'Mudurnu', 'TR14', 'Bolu', 'TR'),
	(425, 'TR1532', 'Muğla Merk', 'TR48', 'Muğla', 'TR'),
	(426, 'TR1533', 'Muradiye', 'TR65', 'Van', 'TR'),
	(427, 'TR1534', 'Muş Merkez', 'TR49', 'Muş', 'TR'),
	(428, 'TR1535', 'Mustafakem', 'TR16', 'Bursa', 'TR'),
	(429, 'TR1536', 'Mut', 'TR33', 'Mersin', 'TR'),
	(430, 'TR1537', 'Mutki', 'TR13', 'Bitlis', 'TR'),
	(431, 'TR1538', 'Muratlı', 'TR59', 'Tekirdağ', 'TR'),
	(432, 'TR1539', 'Nallıhan', 'TR06', 'Ankara', 'TR'),
	(433, 'TR1540', 'Narman', 'TR25', 'Erzurum', 'TR'),
	(434, 'TR1541', 'Nazımiye', 'TR62', 'Tunceli', 'TR'),
	(435, 'TR1542', 'Nazilli', 'TR09', 'Aydın', 'TR'),
	(436, 'TR1543', 'Nevşehir M', 'TR50', 'Nevşehir', 'TR'),
	(437, 'TR1544', 'Niğde Merk', 'TR51', 'Niğde', 'TR'),
	(438, 'TR1545', 'Niksar', 'TR60', 'Tokat', 'TR'),
	(439, 'TR1546', 'Nizip', 'TR27', 'Gaziantep', 'TR'),
	(440, 'TR1547', 'Nusaybin', 'TR47', 'Mardin', 'TR'),
	(441, 'TR1548', 'Of', 'TR61', 'Trabzon', 'TR'),
	(442, 'TR1549', 'Oğuzeli', 'TR27', 'Gaziantep', 'TR'),
	(443, 'TR1550', 'Oltu', 'TR25', 'Erzurum', 'TR'),
	(444, 'TR1551', 'Olur', 'TR25', 'Erzurum', 'TR'),
	(445, 'TR1552', 'Ordu Merke', 'TR52', 'Ordu', 'TR'),
	(446, 'TR1553', 'Orhaneli', 'TR16', 'Bursa', 'TR'),
	(447, 'TR1554', 'Orhangazi', 'TR16', 'Bursa', 'TR'),
	(448, 'TR1555', 'Orta', 'TR18', 'Çankırı', 'TR'),
	(449, 'TR1556', 'Ortaköy / ', 'TR19', 'Çorum', 'TR'),
	(450, 'TR1557', 'Ortaköy / ', 'TR68', 'Aksaray', 'TR'),
	(451, 'TR1558', 'Osmancık', 'TR19', 'Çorum', 'TR'),
	(452, 'TR1559', 'Osmaneli', 'TR11', 'Bilecik', 'TR'),
	(453, 'TR1560', 'Osmaniye M', 'TR80', 'Osmaniye', 'TR'),
	(454, 'TR1561', 'Ovacık / K', 'TR78', 'Karabük', 'TR'),
	(455, 'TR1562', 'Ovacık / T', 'TR62', 'Tunceli', 'TR'),
	(456, 'TR1563', 'Ödemiş', 'TR35', 'İzmir', 'TR'),
	(457, 'TR1564', 'Ömerli', 'TR47', 'Mardin', 'TR'),
	(458, 'TR1565', 'Özalp', 'TR65', 'Van', 'TR'),
	(459, 'TR1566', 'Palu', 'TR23', 'Elazığ', 'TR'),
	(460, 'TR1567', 'Pasinler', 'TR25', 'Erzurum', 'TR'),
	(461, 'TR1568', 'Patnos', 'TR04', 'Ağrı', 'TR'),
	(462, 'TR1569', 'Pazar / Ri', 'TR53', 'Rize', 'TR'),
	(463, 'TR1570', 'Pazarcık', 'TR46', 'Kahramanmaraş', 'TR'),
	(464, 'TR1571', 'Pazaryeri', 'TR11', 'Bilecik', 'TR'),
	(465, 'TR1572', 'Pehlivankö', 'TR39', 'Kırklareli', 'TR'),
	(466, 'TR1573', 'Perşembe', 'TR52', 'Ordu', 'TR'),
	(467, 'TR1574', 'Pertek', 'TR62', 'Tunceli', 'TR'),
	(468, 'TR1575', 'Pervari', 'TR56', 'Siirt', 'TR'),
	(469, 'TR1576', 'Pınarbaşı ', 'TR38', 'Kayseri', 'TR'),
	(470, 'TR1577', 'Pınarhisar', 'TR39', 'Kırklareli', 'TR'),
	(471, 'TR1578', 'Polatlı', 'TR06', 'Ankara', 'TR'),
	(472, 'TR1579', 'Posof', 'TR75', 'Ardahan', 'TR'),
	(473, 'TR1580', 'Pozantı', 'TR01', 'Adana', 'TR'),
	(474, 'TR1581', 'Pülümür', 'TR62', 'Tunceli', 'TR'),
	(475, 'TR1582', 'Pütürge', 'TR44', 'Malatya', 'TR'),
	(476, 'TR1583', 'Refahiye', 'TR24', 'Erzincan', 'TR'),
	(477, 'TR1584', 'Reşadiye', 'TR60', 'Tokat', 'TR'),
	(478, 'TR1585', 'Reyhanlı', 'TR31', 'Hatay', 'TR'),
	(479, 'TR1586', 'Rize Merke', 'TR53', 'Rize', 'TR'),
	(480, 'TR1587', 'Safranbolu', 'TR78', 'Karabük', 'TR'),
	(481, 'TR1588', 'Saimbeyli', 'TR01', 'Adana', 'TR'),
	(482, 'TR1589', 'Sakarya Me', 'TR54', 'Sakarya', 'TR'),
	(483, 'TR1590', 'Salihli', 'TR45', 'Manisa', 'TR'),
	(484, 'TR1591', 'Samandağ', 'TR31', 'Hatay', 'TR'),
	(485, 'TR1592', 'Samsat', 'TR02', 'Adıyaman', 'TR'),
	(486, 'TR1593', 'Samsun Mer', 'TR55', 'Samsun', 'TR'),
	(487, 'TR1594', 'Sandıklı', 'TR03', 'Afyonkarahisar', 'TR'),
	(488, 'TR1595', 'Sapanca', 'TR54', 'Sakarya', 'TR'),
	(489, 'TR1596', 'Saray / Te', 'TR59', 'Tekirdağ', 'TR'),
	(490, 'TR1597', 'Sarayköy', 'TR20', 'Denizli', 'TR'),
	(491, 'TR1598', 'Sarayönü', 'TR42', 'Konya', 'TR'),
	(492, 'TR1599', 'Sarıcakaya', 'TR26', 'Eskişehir', 'TR'),
	(493, 'TR1600', 'Sarıgöl', 'TR45', 'Manisa', 'TR'),
	(494, 'TR1601', 'Sarıkamış', 'TR36', 'Kars', 'TR'),
	(495, 'TR1602', 'Sarıkaya', 'TR66', 'Yozgat', 'TR'),
	(496, 'TR1603', 'Sarıoğlan', 'TR38', 'Kayseri', 'TR'),
	(497, 'TR1604', 'Sarıyer', 'TR34', 'İstanbul', 'TR'),
	(498, 'TR1605', 'Sarız', 'TR38', 'Kayseri', 'TR'),
	(499, 'TR1606', 'Saruhanlı', 'TR45', 'Manisa', 'TR'),
	(500, 'TR1607', 'Sason', 'TR72', 'Batman', 'TR');
INSERT INTO public.ilce VALUES
	(501, 'TR1608', 'Savaştepe', 'TR10', 'Balıkesir', 'TR'),
	(502, 'TR1609', 'Savur', 'TR47', 'Mardin', 'TR'),
	(503, 'TR1610', 'Seben', 'TR14', 'Bolu', 'TR'),
	(504, 'TR1611', 'Seferihisa', 'TR35', 'İzmir', 'TR'),
	(505, 'TR1612', 'Selçuk', 'TR35', 'İzmir', 'TR'),
	(506, 'TR1613', 'Selendi', 'TR45', 'Manisa', 'TR'),
	(507, 'TR1614', 'Selim', 'TR36', 'Kars', 'TR'),
	(508, 'TR1615', 'Senirkent', 'TR32', 'Isparta', 'TR'),
	(509, 'TR1616', 'Serik', 'TR07', 'Antalya', 'TR'),
	(510, 'TR1617', 'Seydişehir', 'TR42', 'Konya', 'TR'),
	(511, 'TR1618', 'Seyitgazi', 'TR26', 'Eskişehir', 'TR'),
	(512, 'TR1619', 'Sındırgı', 'TR10', 'Balıkesir', 'TR'),
	(513, 'TR1620', 'Siirt Merk', 'TR56', 'Siirt', 'TR'),
	(514, 'TR1621', 'Silifke', 'TR33', 'Mersin', 'TR'),
	(515, 'TR1622', 'Silivri', 'TR34', 'İstanbul', 'TR'),
	(516, 'TR1623', 'Silopi', 'TR73', 'Şırnak', 'TR'),
	(517, 'TR1624', 'Silvan', 'TR21', 'Diyarbakır', 'TR'),
	(518, 'TR1625', 'Simav', 'TR43', 'Kütahya', 'TR'),
	(519, 'TR1626', 'Sinanpaşa', 'TR03', 'Afyonkarahisar', 'TR'),
	(520, 'TR1627', 'Sinop Merk', 'TR57', 'Sinop', 'TR'),
	(521, 'TR1628', 'Sivas Merk', 'TR58', 'Sivas', 'TR'),
	(522, 'TR1629', 'Sivaslı', 'TR64', 'Uşak', 'TR'),
	(523, 'TR1630', 'Siverek', 'TR63', 'Şanlıurfa', 'TR'),
	(524, 'TR1631', 'Sivrice', 'TR23', 'Elazığ', 'TR'),
	(525, 'TR1632', 'Sivrihisar', 'TR26', 'Eskişehir', 'TR'),
	(526, 'TR1633', 'Solhan', 'TR12', 'Bingöl', 'TR'),
	(527, 'TR1634', 'Soma', 'TR45', 'Manisa', 'TR'),
	(528, 'TR1635', 'Sorgun', 'TR66', 'Yozgat', 'TR'),
	(529, 'TR1636', 'Söğüt', 'TR11', 'Bilecik', 'TR'),
	(530, 'TR1637', 'Söke', 'TR09', 'Aydın', 'TR'),
	(531, 'TR1638', 'Sulakyurt', 'TR71', 'Kırıkkale', 'TR'),
	(532, 'TR1639', 'Sultandağı', 'TR03', 'Afyonkarahisar', 'TR'),
	(533, 'TR1640', 'Sultanhisa', 'TR09', 'Aydın', 'TR'),
	(534, 'TR1641', 'Suluova', 'TR05', 'Amasya', 'TR'),
	(535, 'TR1642', 'Sungurlu', 'TR19', 'Çorum', 'TR'),
	(536, 'TR1643', 'Suruç', 'TR63', 'Şanlıurfa', 'TR'),
	(537, 'TR1644', 'Susurluk', 'TR10', 'Balıkesir', 'TR'),
	(538, 'TR1645', 'Susuz', 'TR36', 'Kars', 'TR'),
	(539, 'TR1646', 'Suşehri', 'TR58', 'Sivas', 'TR'),
	(540, 'TR1647', 'Sürmene', 'TR61', 'Trabzon', 'TR'),
	(541, 'TR1648', 'Sütçüler', 'TR32', 'Isparta', 'TR'),
	(542, 'TR1649', 'Şabanözü', 'TR18', 'Çankırı', 'TR'),
	(543, 'TR1650', 'Şarkışla', 'TR58', 'Sivas', 'TR'),
	(544, 'TR1651', 'Şarkikaraa', 'TR32', 'Isparta', 'TR'),
	(545, 'TR1652', 'Şarköy', 'TR59', 'Tekirdağ', 'TR'),
	(546, 'TR1653', 'Şavşat', 'TR08', 'Artvin', 'TR'),
	(547, 'TR1654', 'Şebinkarah', 'TR28', 'Giresun', 'TR'),
	(548, 'TR1655', 'Şefaatli', 'TR66', 'Yozgat', 'TR'),
	(549, 'TR1656', 'Şemdinli', 'TR30', 'Hakkari', 'TR'),
	(550, 'TR1657', 'Şenkaya', 'TR25', 'Erzurum', 'TR'),
	(551, 'TR1658', 'Şereflikoç', 'TR06', 'Ankara', 'TR'),
	(552, 'TR1659', 'Şile', 'TR34', 'İstanbul', 'TR'),
	(553, 'TR1660', 'Şiran', 'TR29', 'Gümüşhane', 'TR'),
	(554, 'TR1661', 'Şırnak Mer', 'TR73', 'Şırnak', 'TR'),
	(555, 'TR1662', 'Şirvan', 'TR56', 'Siirt', 'TR'),
	(556, 'TR1663', 'Şişli', 'TR34', 'İstanbul', 'TR'),
	(557, 'TR1664', 'Şuhut', 'TR03', 'Afyonkarahisar', 'TR'),
	(558, 'TR1665', 'Tarsus', 'TR33', 'Mersin', 'TR'),
	(559, 'TR1666', 'Taşköprü', 'TR37', 'Kastamonu', 'TR'),
	(560, 'TR1667', 'Taşlıçay', 'TR04', 'Ağrı', 'TR'),
	(561, 'TR1668', 'Taşova', 'TR05', 'Amasya', 'TR'),
	(562, 'TR1669', 'Tatvan', 'TR13', 'Bitlis', 'TR'),
	(563, 'TR1670', 'Tavas', 'TR20', 'Denizli', 'TR'),
	(564, 'TR1671', 'Tavşanlı', 'TR43', 'Kütahya', 'TR'),
	(565, 'TR1672', 'Tefenni', 'TR15', 'Burdur', 'TR'),
	(566, 'TR1673', 'Tekirdağ M', 'TR59', 'Tekirdağ', 'TR'),
	(567, 'TR1674', 'Tekman', 'TR25', 'Erzurum', 'TR'),
	(568, 'TR1675', 'Tercan', 'TR24', 'Erzincan', 'TR'),
	(569, 'TR1676', 'Terme', 'TR55', 'Samsun', 'TR'),
	(570, 'TR1677', 'Tire', 'TR35', 'İzmir', 'TR'),
	(571, 'TR1678', 'Tirebolu', 'TR28', 'Giresun', 'TR'),
	(572, 'TR1679', 'Tokat Merk', 'TR60', 'Tokat', 'TR'),
	(573, 'TR1680', 'Tomarza', 'TR38', 'Kayseri', 'TR'),
	(574, 'TR1681', 'Tonya', 'TR61', 'Trabzon', 'TR'),
	(575, 'TR1682', 'Torbalı', 'TR35', 'İzmir', 'TR'),
	(576, 'TR1683', 'Tortum', 'TR25', 'Erzurum', 'TR'),
	(577, 'TR1684', 'Torul', 'TR29', 'Gümüşhane', 'TR'),
	(578, 'TR1685', 'Tosya', 'TR37', 'Kastamonu', 'TR'),
	(579, 'TR1686', 'Trabzon Me', 'TR61', 'Trabzon', 'TR'),
	(580, 'TR1687', 'Tufanbeyli', 'TR01', 'Adana', 'TR'),
	(581, 'TR1688', 'Tunceli Me', 'TR62', 'Tunceli', 'TR'),
	(582, 'TR1689', 'Turgutlu', 'TR45', 'Manisa', 'TR'),
	(583, 'TR1690', 'Turhal', 'TR60', 'Tokat', 'TR'),
	(584, 'TR1691', 'Tutak', 'TR04', 'Ağrı', 'TR'),
	(585, 'TR1692', 'Tuzluca', 'TR76', 'Iğdır', 'TR'),
	(586, 'TR1693', 'Türkeli', 'TR57', 'Sinop', 'TR'),
	(587, 'TR1694', 'Türkoğlu', 'TR46', 'Kahramanmaraş', 'TR'),
	(588, 'TR1695', 'Ula', 'TR48', 'Muğla', 'TR'),
	(589, 'TR1696', 'Ulubey / O', 'TR52', 'Ordu', 'TR'),
	(590, 'TR1697', 'Ulubey / U', 'TR64', 'Uşak', 'TR'),
	(591, 'TR1698', 'Uludere', 'TR73', 'Şırnak', 'TR'),
	(592, 'TR1699', 'Uluborlu', 'TR32', 'Isparta', 'TR'),
	(593, 'TR1700', 'Ulukışla', 'TR51', 'Niğde', 'TR'),
	(594, 'TR1701', 'Ulus', 'TR74', 'Bartın', 'TR'),
	(595, 'TR1702', 'Şanlıurfa ', 'TR63', 'Şanlıurfa', 'TR'),
	(596, 'TR1703', 'Urla', 'TR35', 'İzmir', 'TR'),
	(597, 'TR1704', 'Uşak Merke', 'TR64', 'Uşak', 'TR'),
	(598, 'TR1705', 'Uzunköprü', 'TR22', 'Edirne', 'TR'),
	(599, 'TR1706', 'Ünye', 'TR52', 'Ordu', 'TR'),
	(600, 'TR1707', 'Ürgüp', 'TR50', 'Nevşehir', 'TR'),
	(601, 'TR1708', 'Üsküdar', 'TR34', 'İstanbul', 'TR'),
	(602, 'TR1709', 'Vakfıkebir', 'TR61', 'Trabzon', 'TR'),
	(603, 'TR1710', 'Van Merkez', 'TR65', 'Van', 'TR'),
	(604, 'TR1711', 'Varto', 'TR49', 'Muş', 'TR'),
	(605, 'TR1712', 'Vezirköprü', 'TR55', 'Samsun', 'TR'),
	(606, 'TR1713', 'Viranşehir', 'TR63', 'Şanlıurfa', 'TR'),
	(607, 'TR1714', 'Vize', 'TR39', 'Kırklareli', 'TR'),
	(608, 'TR1715', 'Yahyalı', 'TR38', 'Kayseri', 'TR'),
	(609, 'TR1716', 'Yalova Mer', 'TR77', 'Yalova', 'TR'),
	(610, 'TR1717', 'Yalvaç', 'TR32', 'Isparta', 'TR'),
	(611, 'TR1718', 'Yapraklı', 'TR18', 'Çankırı', 'TR'),
	(612, 'TR1719', 'Yatağan', 'TR48', 'Muğla', 'TR'),
	(613, 'TR1720', 'Yavuzeli', 'TR27', 'Gaziantep', 'TR'),
	(614, 'TR1721', 'Yayladağı', 'TR31', 'Hatay', 'TR'),
	(615, 'TR1722', 'Yenice / Ç', 'TR17', 'Çanakkale', 'TR'),
	(616, 'TR1723', 'Yenimahall', 'TR06', 'Ankara', 'TR'),
	(617, 'TR1724', 'Yenipazar ', 'TR09', 'Aydın', 'TR'),
	(618, 'TR1725', 'Yenişehir ', 'TR16', 'Bursa', 'TR'),
	(619, 'TR1726', 'Yerköy', 'TR66', 'Yozgat', 'TR'),
	(620, 'TR1727', 'Yeşilhisar', 'TR38', 'Kayseri', 'TR'),
	(621, 'TR1728', 'Yeşilova', 'TR15', 'Burdur', 'TR'),
	(622, 'TR1729', 'Yeşilyurt ', 'TR44', 'Malatya', 'TR'),
	(623, 'TR1730', 'Yığılca', 'TR81', 'Düzce', 'TR'),
	(624, 'TR1731', 'Yıldızeli', 'TR58', 'Sivas', 'TR'),
	(625, 'TR1732', 'Yomra', 'TR61', 'Trabzon', 'TR'),
	(626, 'TR1733', 'Yozgat Mer', 'TR66', 'Yozgat', 'TR'),
	(627, 'TR1734', 'Yumurtalık', 'TR01', 'Adana', 'TR'),
	(628, 'TR1735', 'Yunak', 'TR42', 'Konya', 'TR'),
	(629, 'TR1736', 'Yusufeli', 'TR08', 'Artvin', 'TR'),
	(630, 'TR1737', 'Yüksekova', 'TR30', 'Hakkari', 'TR'),
	(631, 'TR1738', 'Zara', 'TR58', 'Sivas', 'TR'),
	(632, 'TR1739', 'Zeytinburn', 'TR34', 'İstanbul', 'TR'),
	(633, 'TR1740', 'Zile', 'TR60', 'Tokat', 'TR'),
	(634, 'TR1741', 'Zonguldak ', 'TR67', 'Zonguldak', 'TR'),
	(635, 'TR1742', 'Dalaman', 'TR48', 'Muğla', 'TR'),
	(636, 'TR1743', 'Düziçi', 'TR80', 'Osmaniye', 'TR'),
	(637, 'TR1744', 'Gölbaşı / ', 'TR06', 'Ankara', 'TR'),
	(638, 'TR1745', 'Keçiören', 'TR06', 'Ankara', 'TR'),
	(639, 'TR1746', 'Mamak', 'TR06', 'Ankara', 'TR'),
	(640, 'TR1747', 'Sincan', 'TR06', 'Ankara', 'TR'),
	(641, 'TR1748', 'Yüreğir', 'TR01', 'Adana', 'TR'),
	(642, 'TR1749', 'Acıgöl', 'TR50', 'Nevşehir', 'TR'),
	(643, 'TR1750', 'Adaklı', 'TR12', 'Bingöl', 'TR'),
	(644, 'TR1751', 'Ahmetli', 'TR45', 'Manisa', 'TR'),
	(645, 'TR1752', 'Akkışla', 'TR38', 'Kayseri', 'TR'),
	(646, 'TR1753', 'Akören', 'TR42', 'Konya', 'TR'),
	(647, 'TR1754', 'Akpınar', 'TR40', 'Kırşehir', 'TR'),
	(648, 'TR1755', 'Aksu / Isp', 'TR32', 'Isparta', 'TR'),
	(649, 'TR1756', 'Akyaka', 'TR36', 'Kars', 'TR'),
	(650, 'TR1757', 'Aladağ', 'TR01', 'Adana', 'TR'),
	(651, 'TR1758', 'Alaplı', 'TR67', 'Zonguldak', 'TR'),
	(652, 'TR1759', 'Alpu', 'TR26', 'Eskişehir', 'TR'),
	(653, 'TR1760', 'Altınekin', 'TR42', 'Konya', 'TR'),
	(654, 'TR1761', 'Amasra', 'TR74', 'Bartın', 'TR'),
	(655, 'TR1762', 'Arıcak', 'TR23', 'Elazığ', 'TR'),
	(656, 'TR1763', 'Asarcık', 'TR55', 'Samsun', 'TR'),
	(657, 'TR1764', 'Aslanapa', 'TR43', 'Kütahya', 'TR'),
	(658, 'TR1765', 'Atkaracala', 'TR18', 'Çankırı', 'TR'),
	(659, 'TR1766', 'Aydıncık /', 'TR33', 'Mersin', 'TR'),
	(660, 'TR1767', 'Aydıntepe', 'TR69', 'Bayburt', 'TR'),
	(661, 'TR1768', 'Ayrancı', 'TR70', 'Karaman', 'TR'),
	(662, 'TR1769', 'Babadağ', 'TR20', 'Denizli', 'TR'),
	(663, 'TR1770', 'Bahçesaray', 'TR65', 'Van', 'TR'),
	(664, 'TR1771', 'Başmakçı', 'TR03', 'Afyonkarahisar', 'TR'),
	(665, 'TR1772', 'Battalgazi', 'TR44', 'Malatya', 'TR'),
	(666, 'TR1773', 'Bayat / Af', 'TR03', 'Afyonkarahisar', 'TR'),
	(667, 'TR1774', 'Bekilli', 'TR20', 'Denizli', 'TR'),
	(668, 'TR1775', 'Beşikdüzü', 'TR61', 'Trabzon', 'TR'),
	(669, 'TR1776', 'Beydağ', 'TR35', 'İzmir', 'TR'),
	(670, 'TR1777', 'Beylikova', 'TR26', 'Eskişehir', 'TR'),
	(671, 'TR1778', 'Boğazkale', 'TR19', 'Çorum', 'TR'),
	(672, 'TR1779', 'Bozyazı', 'TR33', 'Mersin', 'TR'),
	(673, 'TR1780', 'Buca', 'TR35', 'İzmir', 'TR'),
	(674, 'TR1781', 'Buharkent', 'TR09', 'Aydın', 'TR'),
	(675, 'TR1782', 'Büyükçekme', 'TR34', 'İstanbul', 'TR'),
	(676, 'TR1783', 'Büyükorhan', 'TR16', 'Bursa', 'TR'),
	(677, 'TR1784', 'Cumayeri', 'TR81', 'Düzce', 'TR'),
	(678, 'TR1785', 'Çağlayance', 'TR46', 'Kahramanmaraş', 'TR'),
	(679, 'TR1786', 'Çaldıran', 'TR65', 'Van', 'TR'),
	(680, 'TR1787', 'Dargeçit', 'TR47', 'Mardin', 'TR'),
	(681, 'TR1788', 'Demirözü', 'TR69', 'Bayburt', 'TR'),
	(682, 'TR1789', 'Derebucak', 'TR42', 'Konya', 'TR'),
	(683, 'TR1790', 'Dumlupınar', 'TR43', 'Kütahya', 'TR'),
	(684, 'TR1791', 'Eğil', 'TR21', 'Diyarbakır', 'TR'),
	(685, 'TR1792', 'Erzin', 'TR31', 'Hatay', 'TR'),
	(686, 'TR1793', 'Gölmarmara', 'TR45', 'Manisa', 'TR'),
	(687, 'TR1794', 'Gölyaka', 'TR81', 'Düzce', 'TR'),
	(688, 'TR1795', 'Gülyalı', 'TR52', 'Ordu', 'TR'),
	(689, 'TR1796', 'Güneysu', 'TR53', 'Rize', 'TR'),
	(690, 'TR1797', 'Gürgentepe', 'TR52', 'Ordu', 'TR'),
	(691, 'TR1798', 'Güroymak', 'TR13', 'Bitlis', 'TR'),
	(692, 'TR1799', 'Harmancık', 'TR16', 'Bursa', 'TR'),
	(693, 'TR1800', 'Harran', 'TR63', 'Şanlıurfa', 'TR'),
	(694, 'TR1801', 'Hasköy', 'TR49', 'Muş', 'TR'),
	(695, 'TR1802', 'Hisarcık', 'TR43', 'Kütahya', 'TR'),
	(696, 'TR1803', 'Honaz', 'TR20', 'Denizli', 'TR'),
	(697, 'TR1804', 'Hüyük', 'TR42', 'Konya', 'TR'),
	(698, 'TR1805', 'İhsangazi', 'TR37', 'Kastamonu', 'TR'),
	(699, 'TR1806', 'İmamoğlu', 'TR01', 'Adana', 'TR'),
	(700, 'TR1807', 'İncirliova', 'TR09', 'Aydın', 'TR'),
	(701, 'TR1808', 'İnönü', 'TR26', 'Eskişehir', 'TR'),
	(702, 'TR1809', 'İscehisar', 'TR03', 'Afyonkarahisar', 'TR'),
	(703, 'TR1810', 'Kağıthane', 'TR34', 'İstanbul', 'TR'),
	(704, 'TR1811', 'Demre', 'TR07', 'Antalya', 'TR'),
	(705, 'TR1812', 'Karaçoban', 'TR25', 'Erzurum', 'TR'),
	(706, 'TR1813', 'Karamanlı', 'TR15', 'Burdur', 'TR'),
	(707, 'TR1814', 'Karatay', 'TR42', 'Konya', 'TR'),
	(708, 'TR1815', 'Kazan', 'TR06', 'Ankara', 'TR'),
	(709, 'TR1816', 'Kemer / Bu', 'TR15', 'Burdur', 'TR'),
	(710, 'TR1817', 'Kızılırmak', 'TR18', 'Çankırı', 'TR'),
	(711, 'TR1818', 'Kocaali', 'TR54', 'Sakarya', 'TR'),
	(712, 'TR1819', 'Konak', 'TR35', 'İzmir', 'TR'),
	(713, 'TR1820', 'Kovancılar', 'TR23', 'Elazığ', 'TR'),
	(714, 'TR1821', 'Körfez', 'TR41', 'Kocaeli', 'TR'),
	(715, 'TR1822', 'Köse', 'TR29', 'Gümüşhane', 'TR'),
	(716, 'TR1823', 'Küçükçekme', 'TR34', 'İstanbul', 'TR'),
	(717, 'TR1824', 'Marmara', 'TR10', 'Balıkesir', 'TR'),
	(718, 'TR1825', 'Marmaraere', 'TR59', 'Tekirdağ', 'TR'),
	(719, 'TR1826', 'Menderes', 'TR35', 'İzmir', 'TR'),
	(720, 'TR1827', 'Meram', 'TR42', 'Konya', 'TR'),
	(721, 'TR1828', 'Murgul', 'TR08', 'Artvin', 'TR'),
	(722, 'TR1829', 'Nilüfer', 'TR16', 'Bursa', 'TR'),
	(723, 'TR1830', '19 Mayıs', 'TR55', 'Samsun', 'TR'),
	(724, 'TR1831', 'Ortaca', 'TR48', 'Muğla', 'TR'),
	(725, 'TR1832', 'Osmangazi', 'TR16', 'Bursa', 'TR'),
	(726, 'TR1833', 'Pamukova', 'TR54', 'Sakarya', 'TR'),
	(727, 'TR1834', 'Pazar / To', 'TR60', 'Tokat', 'TR'),
	(728, 'TR1835', 'Pendik', 'TR34', 'İstanbul', 'TR'),
	(729, 'TR1836', 'Pınarbaşı ', 'TR37', 'Kastamonu', 'TR'),
	(730, 'TR1837', 'Piraziz', 'TR28', 'Giresun', 'TR'),
	(731, 'TR1838', 'Salıpazarı', 'TR55', 'Samsun', 'TR'),
	(732, 'TR1839', 'Selçuklu', 'TR42', 'Konya', 'TR'),
	(733, 'TR1840', 'Serinhisar', 'TR20', 'Denizli', 'TR'),
	(734, 'TR1841', 'Şahinbey', 'TR27', 'Gaziantep', 'TR'),
	(735, 'TR1842', 'Şalpazarı', 'TR61', 'Trabzon', 'TR'),
	(736, 'TR1843', 'Şaphane', 'TR43', 'Kütahya', 'TR'),
	(737, 'TR1844', 'Şehitkamil', 'TR27', 'Gaziantep', 'TR'),
	(738, 'TR1845', 'Şenpazar', 'TR37', 'Kastamonu', 'TR'),
	(739, 'TR1846', 'Talas', 'TR38', 'Kayseri', 'TR'),
	(740, 'TR1847', 'Taraklı', 'TR54', 'Sakarya', 'TR'),
	(741, 'TR1848', 'Taşkent', 'TR42', 'Konya', 'TR'),
	(742, 'TR1849', 'Tekkeköy', 'TR55', 'Samsun', 'TR'),
	(743, 'TR1850', 'Uğurludağ', 'TR19', 'Çorum', 'TR'),
	(744, 'TR1851', 'Uzundere', 'TR25', 'Erzurum', 'TR'),
	(745, 'TR1852', 'Ümraniye', 'TR34', 'İstanbul', 'TR'),
	(746, 'TR1853', 'Üzümlü', 'TR24', 'Erzincan', 'TR'),
	(747, 'TR1854', 'Yağlıdere', 'TR28', 'Giresun', 'TR'),
	(748, 'TR1855', 'Yayladere', 'TR12', 'Bingöl', 'TR'),
	(749, 'TR1856', 'Yenice / K', 'TR78', 'Karabük', 'TR'),
	(750, 'TR1857', 'Yenipazar ', 'TR11', 'Bilecik', 'TR');
INSERT INTO public.ilce VALUES
	(751, 'TR1858', 'Yeşilyurt ', 'TR60', 'Tokat', 'TR'),
	(752, 'TR1859', 'Yıldırım', 'TR16', 'Bursa', 'TR'),
	(753, 'TR1860', 'Ağaçören', 'TR68', 'Aksaray', 'TR'),
	(754, 'TR1861', 'Güzelyurt', 'TR68', 'Aksaray', 'TR'),
	(755, 'TR1862', 'Kazımkarab', 'TR70', 'Karaman', 'TR'),
	(756, 'TR1863', 'Kocasinan', 'TR38', 'Kayseri', 'TR'),
	(757, 'TR1864', 'Melikgazi', 'TR38', 'Kayseri', 'TR'),
	(758, 'TR1865', 'Pazaryolu', 'TR25', 'Erzurum', 'TR'),
	(759, 'TR1866', 'Sarıyahşi', 'TR68', 'Aksaray', 'TR'),
	(760, 'TR1867', 'Ağlı', 'TR37', 'Kastamonu', 'TR'),
	(761, 'TR1868', 'Ahırlı', 'TR42', 'Konya', 'TR'),
	(762, 'TR1869', 'Akçakent', 'TR40', 'Kırşehir', 'TR'),
	(763, 'TR1870', 'Akıncılar', 'TR58', 'Sivas', 'TR'),
	(764, 'TR1871', 'Pamukkale', 'TR20', 'Denizli', 'TR'),
	(765, 'TR1872', 'Akyurt', 'TR06', 'Ankara', 'TR'),
	(766, 'TR1873', 'Alacakaya', 'TR23', 'Elazığ', 'TR'),
	(767, 'TR1874', 'Altınyayla', 'TR15', 'Burdur', 'TR'),
	(768, 'TR1875', 'Altınyayla', 'TR58', 'Sivas', 'TR'),
	(769, 'TR1876', 'Altunhisar', 'TR51', 'Niğde', 'TR'),
	(770, 'TR1877', 'Aydıncık /', 'TR66', 'Yozgat', 'TR'),
	(771, 'TR1878', 'Tillo', 'TR56', 'Siirt', 'TR'),
	(772, 'TR1879', 'Ayvacık / ', 'TR55', 'Samsun', 'TR'),
	(773, 'TR1880', 'Bahşili', 'TR71', 'Kırıkkale', 'TR'),
	(774, 'TR1881', 'Baklan', 'TR20', 'Denizli', 'TR'),
	(775, 'TR1882', 'Balışeyh', 'TR71', 'Kırıkkale', 'TR'),
	(776, 'TR1883', 'Başçiftlik', 'TR60', 'Tokat', 'TR'),
	(777, 'TR1884', 'Başyayla', 'TR70', 'Karaman', 'TR'),
	(778, 'TR1885', 'Bayramören', 'TR18', 'Çankırı', 'TR'),
	(779, 'TR1886', 'Bayrampaşa', 'TR34', 'İstanbul', 'TR'),
	(780, 'TR1887', 'Belen', 'TR31', 'Hatay', 'TR'),
	(781, 'TR1888', 'Beyağaç', 'TR20', 'Denizli', 'TR'),
	(782, 'TR1889', 'Bozkurt / ', 'TR20', 'Denizli', 'TR'),
	(783, 'TR1890', 'Boztepe', 'TR40', 'Kırşehir', 'TR'),
	(784, 'TR1891', 'Çamaş', 'TR52', 'Ordu', 'TR'),
	(785, 'TR1892', 'Çamlıyayla', 'TR33', 'Mersin', 'TR'),
	(786, 'TR1893', 'Çamoluk', 'TR28', 'Giresun', 'TR'),
	(787, 'TR1894', 'Çanakçı', 'TR28', 'Giresun', 'TR'),
	(788, 'TR1895', 'Çandır', 'TR66', 'Yozgat', 'TR'),
	(789, 'TR1896', 'Çarşıbaşı', 'TR61', 'Trabzon', 'TR'),
	(790, 'TR1897', 'Çatalpınar', 'TR52', 'Ordu', 'TR'),
	(791, 'TR1898', 'Çavdarhisa', 'TR43', 'Kütahya', 'TR'),
	(792, 'TR1899', 'Çavdır', 'TR15', 'Burdur', 'TR'),
	(793, 'TR1900', 'Çaybaşı', 'TR52', 'Ordu', 'TR'),
	(794, 'TR1901', 'Çelebi', 'TR71', 'Kırıkkale', 'TR'),
	(795, 'TR1902', 'Çeltik', 'TR42', 'Konya', 'TR'),
	(796, 'TR1903', 'Çeltikçi', 'TR15', 'Burdur', 'TR'),
	(797, 'TR1904', 'Çiftlik', 'TR51', 'Niğde', 'TR'),
	(798, 'TR1905', 'Çilimli', 'TR81', 'Düzce', 'TR'),
	(799, 'TR1906', 'Çobanlar', 'TR03', 'Afyonkarahisar', 'TR'),
	(800, 'TR1907', 'Derbent', 'TR42', 'Konya', 'TR'),
	(801, 'TR1908', 'Derepazarı', 'TR53', 'Rize', 'TR'),
	(802, 'TR1909', 'Dernekpaza', 'TR61', 'Trabzon', 'TR'),
	(803, 'TR1910', 'Dikmen', 'TR57', 'Sinop', 'TR'),
	(804, 'TR1911', 'Dodurga', 'TR19', 'Çorum', 'TR'),
	(805, 'TR1912', 'Doğankent', 'TR28', 'Giresun', 'TR'),
	(806, 'TR1913', 'Doğanşar', 'TR58', 'Sivas', 'TR'),
	(807, 'TR1914', 'Doğanyol', 'TR44', 'Malatya', 'TR'),
	(808, 'TR1915', 'Doğanyurt', 'TR37', 'Kastamonu', 'TR'),
	(809, 'TR1916', 'Dörtdivan', 'TR14', 'Bolu', 'TR'),
	(810, 'TR1917', 'Düzköy', 'TR61', 'Trabzon', 'TR'),
	(811, 'TR1918', 'Edremit / ', 'TR65', 'Van', 'TR'),
	(812, 'TR1919', 'Ekinözü', 'TR46', 'Kahramanmaraş', 'TR'),
	(813, 'TR1920', 'Emirgazi', 'TR42', 'Konya', 'TR'),
	(814, 'TR1921', 'Eskil', 'TR68', 'Aksaray', 'TR'),
	(815, 'TR1922', 'Etimesgut', 'TR06', 'Ankara', 'TR'),
	(816, 'TR1923', 'Evciler', 'TR03', 'Afyonkarahisar', 'TR'),
	(817, 'TR1924', 'Evren', 'TR06', 'Ankara', 'TR'),
	(818, 'TR1925', 'Ferizli', 'TR54', 'Sakarya', 'TR'),
	(819, 'TR1926', 'Gökçebey', 'TR67', 'Zonguldak', 'TR'),
	(820, 'TR1927', 'Gölova', 'TR58', 'Sivas', 'TR'),
	(821, 'TR1928', 'Gömeç', 'TR10', 'Balıkesir', 'TR'),
	(822, 'TR1929', 'Gönen / Is', 'TR32', 'Isparta', 'TR'),
	(823, 'TR1930', 'Güce', 'TR28', 'Giresun', 'TR'),
	(824, 'TR1931', 'Güçlükonak', 'TR73', 'Şırnak', 'TR'),
	(825, 'TR1932', 'Gülağaç', 'TR68', 'Aksaray', 'TR'),
	(826, 'TR1933', 'Güneysınır', 'TR42', 'Konya', 'TR'),
	(827, 'TR1934', 'Günyüzü', 'TR26', 'Eskişehir', 'TR'),
	(828, 'TR1935', 'Gürsu', 'TR16', 'Bursa', 'TR'),
	(829, 'TR1936', 'Hacılar', 'TR38', 'Kayseri', 'TR'),
	(830, 'TR1937', 'Halkapınar', 'TR42', 'Konya', 'TR'),
	(831, 'TR1938', 'Hamamözü', 'TR05', 'Amasya', 'TR'),
	(832, 'TR1939', 'Han', 'TR26', 'Eskişehir', 'TR'),
	(833, 'TR1940', 'Hanönü', 'TR37', 'Kastamonu', 'TR'),
	(834, 'TR1941', 'Hasankeyf', 'TR72', 'Batman', 'TR'),
	(835, 'TR1942', 'Hayrat', 'TR61', 'Trabzon', 'TR'),
	(836, 'TR1943', 'Hemşin', 'TR53', 'Rize', 'TR'),
	(837, 'TR1944', 'Hocalar', 'TR03', 'Afyonkarahisar', 'TR'),
	(838, 'TR1945', 'Aziziye', 'TR25', 'Erzurum', 'TR'),
	(839, 'TR1946', 'İbradı', 'TR07', 'Antalya', 'TR'),
	(840, 'TR1947', 'İkizce', 'TR52', 'Ordu', 'TR'),
	(841, 'TR1948', 'İnhisar', 'TR11', 'Bilecik', 'TR'),
	(842, 'TR1949', 'İyidere', 'TR53', 'Rize', 'TR'),
	(843, 'TR1950', 'Kabadüz', 'TR52', 'Ordu', 'TR'),
	(844, 'TR1951', 'Kabataş', 'TR52', 'Ordu', 'TR'),
	(845, 'TR1952', 'Kadışehri', 'TR66', 'Yozgat', 'TR'),
	(846, 'TR1953', 'Kale / Mal', 'TR44', 'Malatya', 'TR'),
	(847, 'TR1954', 'Karakeçili', 'TR71', 'Kırıkkale', 'TR'),
	(848, 'TR1955', 'Karapürçek', 'TR54', 'Sakarya', 'TR'),
	(849, 'TR1956', 'Karkamış', 'TR27', 'Gaziantep', 'TR'),
	(850, 'TR1957', 'Karpuzlu', 'TR09', 'Aydın', 'TR'),
	(851, 'TR1958', 'Kavaklıder', 'TR48', 'Muğla', 'TR'),
	(852, 'TR1959', 'Kemer / An', 'TR07', 'Antalya', 'TR'),
	(853, 'TR1960', 'Kestel', 'TR16', 'Bursa', 'TR'),
	(854, 'TR1961', 'Kızılören', 'TR03', 'Afyonkarahisar', 'TR'),
	(855, 'TR1962', 'Kocaköy', 'TR21', 'Diyarbakır', 'TR'),
	(856, 'TR1963', 'Korgun', 'TR18', 'Çankırı', 'TR'),
	(857, 'TR1964', 'Korkut', 'TR49', 'Muş', 'TR'),
	(858, 'TR1965', 'Köprübaşı ', 'TR45', 'Manisa', 'TR'),
	(859, 'TR1966', 'Köprübaşı ', 'TR61', 'Trabzon', 'TR'),
	(860, 'TR1967', 'Köprüköy', 'TR25', 'Erzurum', 'TR'),
	(861, 'TR1968', 'Köşk', 'TR09', 'Aydın', 'TR'),
	(862, 'TR1969', 'Kuluncak', 'TR44', 'Malatya', 'TR'),
	(863, 'TR1970', 'Kumlu', 'TR31', 'Hatay', 'TR'),
	(864, 'TR1971', 'Kürtün', 'TR29', 'Gümüşhane', 'TR'),
	(865, 'TR1972', 'Laçin', 'TR19', 'Çorum', 'TR'),
	(866, 'TR1973', 'Mihalgazi', 'TR26', 'Eskişehir', 'TR'),
	(867, 'TR1974', 'Nurdağı', 'TR27', 'Gaziantep', 'TR'),
	(868, 'TR1975', 'Nurhak', 'TR46', 'Kahramanmaraş', 'TR'),
	(869, 'TR1976', 'Oğuzlar', 'TR19', 'Çorum', 'TR'),
	(870, 'TR1977', 'Otlukbeli', 'TR24', 'Erzincan', 'TR'),
	(871, 'TR1978', 'Özvatan', 'TR38', 'Kayseri', 'TR'),
	(872, 'TR1979', 'Pazarlar', 'TR43', 'Kütahya', 'TR'),
	(873, 'TR1980', 'Saray / Va', 'TR65', 'Van', 'TR'),
	(874, 'TR1981', 'Saraydüzü', 'TR57', 'Sinop', 'TR'),
	(875, 'TR1982', 'Saraykent', 'TR66', 'Yozgat', 'TR'),
	(876, 'TR1983', 'Sarıvelile', 'TR70', 'Karaman', 'TR'),
	(877, 'TR1984', 'Seydiler', 'TR37', 'Kastamonu', 'TR'),
	(878, 'TR1985', 'Sincik', 'TR02', 'Adıyaman', 'TR'),
	(879, 'TR1986', 'Söğütlü', 'TR54', 'Sakarya', 'TR'),
	(880, 'TR1987', 'Sulusaray', 'TR60', 'Tokat', 'TR'),
	(881, 'TR1988', 'Süloğlu', 'TR22', 'Edirne', 'TR'),
	(882, 'TR1989', 'Tut', 'TR02', 'Adıyaman', 'TR'),
	(883, 'TR1990', 'Tuzlukçu', 'TR42', 'Konya', 'TR'),
	(884, 'TR1991', 'Ulaş', 'TR58', 'Sivas', 'TR'),
	(885, 'TR1992', 'Yahşihan', 'TR71', 'Kırıkkale', 'TR'),
	(886, 'TR1993', 'Yakakent', 'TR55', 'Samsun', 'TR'),
	(887, 'TR1994', 'Yalıhüyük', 'TR42', 'Konya', 'TR'),
	(888, 'TR1995', 'Yazıhan', 'TR44', 'Malatya', 'TR'),
	(889, 'TR1996', 'Yedisu', 'TR12', 'Bingöl', 'TR'),
	(890, 'TR1997', 'Yeniçağa', 'TR14', 'Bolu', 'TR'),
	(891, 'TR1998', 'Yenifakılı', 'TR66', 'Yozgat', 'TR'),
	(892, 'TR2000', 'Didim', 'TR09', 'Aydın', 'TR'),
	(893, 'TR2001', 'Yenişarbad', 'TR32', 'Isparta', 'TR'),
	(894, 'TR2002', 'Yeşilli', 'TR47', 'Mardin', 'TR'),
	(895, 'TR2003', 'Avcılar', 'TR34', 'İstanbul', 'TR'),
	(896, 'TR2004', 'Bağcılar', 'TR34', 'İstanbul', 'TR'),
	(897, 'TR2005', 'Bahçelievl', 'TR34', 'İstanbul', 'TR'),
	(898, 'TR2006', 'Balçova', 'TR35', 'İzmir', 'TR'),
	(899, 'TR2007', 'Çiğli', 'TR35', 'İzmir', 'TR'),
	(900, 'TR2008', 'Damal', 'TR75', 'Ardahan', 'TR'),
	(901, 'TR2009', 'Gaziemir', 'TR35', 'İzmir', 'TR'),
	(902, 'TR2010', 'Güngören', 'TR34', 'İstanbul', 'TR'),
	(903, 'TR2011', 'Karakoyunl', 'TR76', 'Iğdır', 'TR'),
	(904, 'TR2012', 'Maltepe', 'TR34', 'İstanbul', 'TR'),
	(905, 'TR2013', 'Narlıdere', 'TR35', 'İzmir', 'TR'),
	(906, 'TR2014', 'Sultanbeyl', 'TR34', 'İstanbul', 'TR'),
	(907, 'TR2015', 'Tuzla', 'TR34', 'İstanbul', 'TR'),
	(908, 'TR2016', 'Esenler', 'TR34', 'İstanbul', 'TR'),
	(909, 'TR2017', 'Gümüşova', 'TR81', 'Düzce', 'TR'),
	(910, 'TR2018', 'Güzelbahçe', 'TR35', 'İzmir', 'TR'),
	(911, 'TR2019', 'Altınova', 'TR77', 'Yalova', 'TR'),
	(912, 'TR2020', 'Armutlu', 'TR77', 'Yalova', 'TR'),
	(913, 'TR2021', 'Çınarcık', 'TR77', 'Yalova', 'TR'),
	(914, 'TR2022', 'Çiftlikköy', 'TR77', 'Yalova', 'TR'),
	(915, 'TR2023', 'Elbeyli', 'TR79', 'Kilis', 'TR'),
	(916, 'TR2024', 'Musabeyli', 'TR79', 'Kilis', 'TR'),
	(917, 'TR2025', 'Polateli', 'TR79', 'Kilis', 'TR'),
	(918, 'TR2026', 'Termal', 'TR77', 'Yalova', 'TR'),
	(919, 'TR2027', 'Hasanbeyli', 'TR80', 'Osmaniye', 'TR'),
	(920, 'TR2028', 'Sumbas', 'TR80', 'Osmaniye', 'TR'),
	(921, 'TR2029', 'Toprakkale', 'TR80', 'Osmaniye', 'TR'),
	(922, 'TR2030', 'Derince', 'TR41', 'Kocaeli', 'TR'),
	(923, 'TR2031', 'Kaynaşlı', 'TR81', 'Düzce', 'TR'),
	(924, 'TR2032', 'Sarıçam', 'TR01', 'Adana', 'TR'),
	(925, 'TR2033', 'Çukurova', 'TR01', 'Adana', 'TR'),
	(926, 'TR2034', 'Pursaklar', 'TR06', 'Ankara', 'TR'),
	(927, 'TR2035', 'Aksu / Ant', 'TR07', 'Antalya', 'TR'),
	(928, 'TR2036', 'Döşemealtı', 'TR07', 'Antalya', 'TR'),
	(929, 'TR2037', 'Kepez', 'TR07', 'Antalya', 'TR'),
	(930, 'TR2038', 'Konyaaltı', 'TR07', 'Antalya', 'TR'),
	(931, 'TR2039', 'Muratpaşa', 'TR07', 'Antalya', 'TR'),
	(932, 'TR2040', 'Bağlar', 'TR21', 'Diyarbakır', 'TR'),
	(933, 'TR2041', 'Kayapınar', 'TR21', 'Diyarbakır', 'TR'),
	(934, 'TR2042', 'Sur', 'TR21', 'Diyarbakır', 'TR'),
	(935, 'TR2043', 'Yenişehir ', 'TR21', 'Diyarbakır', 'TR'),
	(936, 'TR2044', 'Palandöken', 'TR25', 'Erzurum', 'TR'),
	(937, 'TR2045', 'Yakutiye', 'TR25', 'Erzurum', 'TR'),
	(938, 'TR2046', 'Odunpazarı', 'TR26', 'Eskişehir', 'TR'),
	(939, 'TR2047', 'Tepebaşı', 'TR26', 'Eskişehir', 'TR'),
	(940, 'TR2048', 'Arnavutköy', 'TR34', 'İstanbul', 'TR'),
	(941, 'TR2049', 'Ataşehir', 'TR34', 'İstanbul', 'TR'),
	(942, 'TR2050', 'Başakşehir', 'TR34', 'İstanbul', 'TR'),
	(943, 'TR2051', 'Beylikdüzü', 'TR34', 'İstanbul', 'TR'),
	(944, 'TR2052', 'Çekmeköy', 'TR34', 'İstanbul', 'TR'),
	(945, 'TR2053', 'Esenyurt', 'TR34', 'İstanbul', 'TR'),
	(946, 'TR2054', 'Sancaktepe', 'TR34', 'İstanbul', 'TR'),
	(947, 'TR2055', 'Sultangazi', 'TR34', 'İstanbul', 'TR'),
	(948, 'TR2056', 'Bayraklı', 'TR35', 'İzmir', 'TR'),
	(949, 'TR2057', 'Karabağlar', 'TR35', 'İzmir', 'TR'),
	(950, 'TR2058', 'Başiskele', 'TR41', 'Kocaeli', 'TR'),
	(951, 'TR2059', 'Çayırova', 'TR41', 'Kocaeli', 'TR'),
	(952, 'TR2060', 'Darıca', 'TR41', 'Kocaeli', 'TR'),
	(953, 'TR2061', 'Dilovası', 'TR41', 'Kocaeli', 'TR'),
	(954, 'TR2062', 'İzmit', 'TR41', 'Kocaeli', 'TR'),
	(955, 'TR2063', 'Kartepe', 'TR41', 'Kocaeli', 'TR'),
	(956, 'TR2064', 'Akdeniz', 'TR33', 'Mersin', 'TR'),
	(957, 'TR2065', 'Mezitli', 'TR33', 'Mersin', 'TR'),
	(958, 'TR2066', 'Toroslar', 'TR33', 'Mersin', 'TR'),
	(959, 'TR2067', 'Yenişehir ', 'TR33', 'Mersin', 'TR'),
	(960, 'TR2068', 'Adapazarı', 'TR54', 'Sakarya', 'TR'),
	(961, 'TR2069', 'Arifiye', 'TR54', 'Sakarya', 'TR'),
	(962, 'TR2070', 'Erenler', 'TR54', 'Sakarya', 'TR'),
	(963, 'TR2071', 'Serdivan', 'TR54', 'Sakarya', 'TR'),
	(964, 'TR2072', 'Atakum', 'TR55', 'Samsun', 'TR'),
	(965, 'TR2073', 'Canik', 'TR55', 'Samsun', 'TR'),
	(966, 'TR2074', 'İlkadım', 'TR55', 'Samsun', 'TR'),
	(967, 'TR2076', 'Efeler', 'TR09', 'Aydın', 'TR'),
	(968, 'TR2077', 'Altıeylül', 'TR10', 'Balıkesir', 'TR'),
	(969, 'TR2078', 'Karesi', 'TR10', 'Balıkesir', 'TR'),
	(970, 'TR2079', 'Merkezefen', 'TR20', 'Denizli', 'TR'),
	(971, 'TR2080', 'Antakya', 'TR31', 'Hatay', 'TR'),
	(972, 'TR2081', 'Arsuz', 'TR31', 'Hatay', 'TR'),
	(973, 'TR2082', 'Defne', 'TR31', 'Hatay', 'TR'),
	(974, 'TR2083', 'Payas', 'TR31', 'Hatay', 'TR'),
	(975, 'TR2084', 'Dulkadiroğ', 'TR46', 'Kahramanmaraş', 'TR'),
	(976, 'TR2085', 'Onikişubat', 'TR46', 'Kahramanmaraş', 'TR'),
	(977, 'TR2086', 'Şehzadeler', 'TR45', 'Manisa', 'TR'),
	(978, 'TR2087', 'Yunusemre', 'TR45', 'Manisa', 'TR'),
	(979, 'TR2088', 'Artuklu', 'TR47', 'Mardin', 'TR'),
	(980, 'TR2089', 'Menteşe', 'TR48', 'Muğla', 'TR'),
	(981, 'TR2090', 'Seydikemer', 'TR48', 'Muğla', 'TR'),
	(982, 'TR2091', 'Eyyübiye', 'TR63', 'Şanlıurfa', 'TR'),
	(983, 'TR2092', 'Haliliye', 'TR63', 'Şanlıurfa', 'TR'),
	(984, 'TR2093', 'Karaköprü', 'TR63', 'Şanlıurfa', 'TR'),
	(985, 'TR2094', 'Ergene', 'TR59', 'Tekirdağ', 'TR'),
	(986, 'TR2095', 'Kapaklı', 'TR59', 'Tekirdağ', 'TR'),
	(987, 'TR2096', 'Süleymanpa', 'TR59', 'Tekirdağ', 'TR'),
	(988, 'TR2097', 'Ortahisar', 'TR61', 'Trabzon', 'TR'),
	(989, 'TR2098', 'İpekyolu', 'TR65', 'Van', 'TR'),
	(990, 'TR2099', 'Tuşba', 'TR65', 'Van', 'TR'),
	(991, 'TR2100', 'Kilimli', 'TR67', 'Zonguldak', 'TR'),
	(992, 'TR2101', 'Kozlu', 'TR67', 'Zonguldak', 'TR'),
	(993, 'TR2103', 'Altınordu', 'TR52', 'Ordu', 'TR'),
	(994, 'asdf sdg df', 'dsdfsdfgsdgs', 'TR01', NULL, 'DE');


--
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kategori VALUES
	(4, 'ürün', 2),
	(6, 'sdas', 234);


--
-- Data for Name: kisi_adres; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: kisiler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kisiler VALUES
	(2, 'ali', 'çam', 33656547891, 'E', 8526668541, 'asldisf@ss.com', NULL, NULL, NULL, NULL, NULL, NULL),
	(3, 'veli', 'çam', 33656547891, 'E', 8526668541, 'asldisf@ss.com', NULL, NULL, NULL, NULL, NULL, NULL),
	(4, 'dsfg fg j', 'dfgshfj', 33656547891, 'E', 8526668541, 'asldisf@ss.com', NULL, NULL, NULL, NULL, NULL, NULL),
	(12, 'c kullanıcı', 'c soyadı', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(13, 'abcc cff', 'qwerwtydhn', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(14, 'sadfrasf', 'sdfsg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(15, 'ASDASD', 'ASDA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(16, 'kullanıcı c', 'kullanıcı c', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(17, 'asd', 'sad', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(18, 'c kullanıcı', '1325', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(19, 'c kullanıcı', '1325', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(20, 'c kullanıcı', '1325', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(21, 'c kullanıcı', '1325', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(22, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(23, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(24, 'asd', 'qwe', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(25, '123', 'abdulsamed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(26, '123', 'abdulsamed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(27, 'abdulsamed', 'çam', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(28, '123', 'abdulsamed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(29, '123', 'abdulsamed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(30, '1233123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(31, '1233123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(32, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(33, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(34, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(35, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(36, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(37, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(38, 'c kullanıcı', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(39, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(40, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(41, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(42, '123', 'samed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(43, '42', '123', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(44, '42', '123', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(47, 'abdulsamed', 'çam', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(48, 'abdulsamed', 'çam', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(49, '123', 'abdulsamed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(50, '123', 'abdulsamed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(51, 'hgj khlnk', 'bgvmngbhb kb', 789654321, 'K', NULL, '', '', '', '', '                                                                                                                                                                                                                                                               ', '', NULL),
	(52, 'hgj khlnk', 'bgvmngbhb kb', 789654321, 'K', NULL, '', '', '', '', '                                                                                                                                                                                                                                                               ', '', NULL),
	(53, 'ngfhvbök nl', '', 4564654, NULL, NULL, '', '', '', '', '                                                                                                                                                                                                                                                               ', '', NULL),
	(54, 'bnvmnvbjhbj', '', 32323223, NULL, NULL, '', '', '', '', '                                                                                                                                                                                                                                                               ', '', NULL);


--
-- Data for Name: kullanici_grubu; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: kullanici_yetkileri; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: kullanicilar; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kullanicilar VALUES
	(4, NULL, NULL, NULL),
	(16, 'c kullanıcı', '1325', NULL),
	(17, 'dsa', '123', NULL),
	(18, 'asda', '16', NULL),
	(19, 'asdas', '1232', 2),
	(20, 'asda', '1232', 2),
	(24, 'asd', '123', 4),
	(27, 'asd', '132', 2),
	(47, 'asmd', '123', 2),
	(48, 'asmd', '123', 7);


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.log VALUES
	(1, 'urunler', 30, NULL, 'Yeni kayıt eklendi', 'log çalışacak mı'),
	(2, 'urunler', 31, NULL, 'Yeni kayıt eklendi', '(31,"log deneem iki",,,,,,,)'),
	(3, 'urunler', 33, NULL, 'Yeni kayıt eklendi', '(33,"log deneem üç",,,,,,,)'),
	(4, 'urunler', 34, NULL, 'Yeni kayıt eklendi', '(34,"log deneem dört",,,,,,,)'),
	(5, 'musteri', 33, NULL, 'Yeni kayıt eklendi', '(33,,"müşteri log",,,,,,,,,,)'),
	(6, 'urunler', 24, NULL, 'Kayıt silindi', '(24,ürün14,0,5,10,15,20,asda,)'),
	(7, 'musteri', 34, NULL, 'Yeni kayıt eklendi', '(34,3526,sadas,sdad,K,,"","","","","","",)'),
	(8, 'musteri', 35, NULL, 'Yeni kayıt eklendi', '(35,123,qwe,qwe,E,123213,aweqw@gmail.com,eqwe,"","","",aslanbey,156365)'),
	(9, 'musteri', 36, NULL, 'Yeni kayıt eklendi', '(36,123123,"",asda,K,1235,"","","","","","",)'),
	(10, 'musteri', 37, NULL, 'Yeni kayıt eklendi', '(37,123123,"",asda,K,1235,"","","","","","",)'),
	(11, 'musteri', 38, NULL, 'Yeni kayıt eklendi', '(38,135135,abdulsamed,çam,E,5436252,samed8221@gmail.com,asddfg,"","","",aslanbey,156)'),
	(12, 'urunler', 31, '(31,"ürün onbeş",,,,,,,)', 'Kayıt Güncellendi', '(31,"ürün dört",,,,,,,)'),
	(13, 'urunler', 25, '(25,"ürün onbeş",10,20,30,40,50,asd,)', 'Kayıt Güncellendi', '(25,"ürün onbeş",10,20,30,40,50,asd,100)'),
	(14, 'urunler', 27, '(27,"ürün onbeş",10,20,30,40,50,asd,)', 'Kayıt Güncellendi', '(27,"ürün onbeş",10,20,30,40,50,asd,100)'),
	(15, 'urunler', 30, '(30,"ürün onbeş",,,,,,,)', 'Kayıt Güncellendi', '(30,"ürün onbeş",,,,,,,100)'),
	(16, 'urunler', 33, '(33,"ürün onbeş",,,,,,,)', 'Kayıt Güncellendi', '(33,"ürün onbeş",,,,,,,100)'),
	(17, 'urunler', 20, '(20,"ürün bir",0,5,10,15,20,asd,)', 'Kayıt Güncellendi', '(20,"ürün bir",0,5,10,15,20,asd,100)'),
	(18, 'urunler', 34, '(34,"ürün iki",,,,,,,)', 'Kayıt Güncellendi', '(34,"ürün iki",,,,,,,100)'),
	(19, 'urunler', 31, '(31,"ürün dört",,,,,,,)', 'Kayıt Güncellendi', '(31,"ürün dört",,,,,,,100)'),
	(20, 'urunler', 34, '(34,"ürün iki",,,,,,,100)', 'Kayıt Güncellendi', '(34,"ürün iki",,,,,,,95)'),
	(21, 'urunler', 25, '(25,"ürün onbeş",10,20,30,40,50,asd,100)', 'Kayıt Güncellendi', '(25,"ürün onbeş",10,20,30,40,50,asd,98)'),
	(22, 'urunler', 33, '(33,"ürün onbeş",,,,,,,100)', 'Kayıt Güncellendi', '(33,"ürün onbeş",,,,,,,98)');


--
-- Data for Name: musteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteri VALUES
	(3, NULL),
	(54, NULL);


--
-- Data for Name: musteri2; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteri2 VALUES
	(20, 123123, 'adas', 'asda', 'K', 1235, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(23, 1231, 'adas', 'sdad', NULL, 23123, '', '', NULL, NULL, NULL, NULL, NULL),
	(21, 12312, '12312', 'adı', 'soyadı', 231, 'xyz@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL),
	(22, 213123, 'adsafsd', 'asdfasdfas', 'E', NULL, '', 'asdas mahallesi', NULL, NULL, NULL, NULL, NULL),
	(26, 3526, 'adas', 'sdad', 'K', NULL, '', '', '', '', '', NULL, NULL),
	(27, 3526, 'sadas', 'sdad', 'K', NULL, '', '', '', '', '', NULL, NULL),
	(28, 4564, 'sadas', 'sdad', 'K', NULL, '', '', '', '', '', NULL, NULL),
	(29, 1234567, 'cxvbnvm', 'xbvncbm', 'K', NULL, '', '', '', '', '', '', NULL),
	(30, 43565, 'rtgfhyd h jufgkhıl', 'sadfgh', NULL, NULL, '', '', '', '', '', 'ertr', NULL),
	(31, 1234, 'asdfgh', 'sdfgh', NULL, NULL, '', '', '', '', '', 'asrdfsg', 12345678),
	(32, NULL, 'müşteri deneme', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(33, NULL, 'müşteri log', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(34, 3526, 'sadas', 'sdad', 'K', NULL, '', '', '', '', '', '', NULL),
	(38, 46456, 'abdulsamed', 'çam', 'K', 5436252, 'samed8221@gmail.com', 'asddfg', '', '', '', 'selcuklu', 156);


--
-- Data for Name: sehir; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sehir VALUES
	(1, 'MXOAX', 'Oaxaca', 'MX'),
	(2, NULL, 'Niue', 'NU'),
	(3, NULL, 'Yabucoa', 'PR'),
	(4, 'AD02', 'Canillo', 'AD'),
	(5, 'AD03', 'Encamp', 'AD'),
	(6, 'AD04', 'La Massana', 'AD'),
	(7, 'AD05', 'Ordino', 'AD'),
	(8, 'AD06', 'Sant Julia de Loria', 'AD'),
	(9, 'AD07', 'Andorra la Vella', 'AD'),
	(10, 'AD08', 'Escaldes-Engordany', 'AD'),
	(11, 'AEAJ', 'Ajman', 'AE'),
	(12, 'AEAZ', 'Abu Zaby', 'AE'),
	(13, 'AEDU', 'Dubayy', 'AE'),
	(14, 'AEFU', 'Al Fujayrah', 'AE'),
	(15, 'AERK', 'Ras al Khaymah', 'AE'),
	(16, 'AESH', 'Ash Shariqah', 'AE'),
	(17, 'AEUQ', 'Umm al Qaywayn', 'AE'),
	(18, 'AFBAL', 'Balkh', 'AF'),
	(19, 'AFBAM', 'Bamyan', 'AF'),
	(20, 'AFBDG', 'Badghis', 'AF'),
	(21, 'AFBDS', 'Badakhshan', 'AF'),
	(22, 'AFBGL', 'Baghlan', 'AF'),
	(23, 'AFDAY', 'Daykundi', 'AF'),
	(24, 'AFFRA', 'Farah', 'AF'),
	(25, 'AFFYB', 'Faryab', 'AF'),
	(26, 'AFGHA', 'Ghazni', 'AF'),
	(27, 'AFGHO', 'Ghor', 'AF'),
	(28, 'AFHEL', 'Helmand', 'AF'),
	(29, 'AFHER', 'Herat', 'AF'),
	(30, 'AFJOW', 'Jowzjan', 'AF'),
	(31, 'AFKAB', 'Kabul', 'AF'),
	(32, 'AFKAN', 'Kandahar', 'AF'),
	(33, 'AFKAP', 'Kapisa', 'AF'),
	(34, 'AFKDZ', 'Kunduz', 'AF'),
	(35, 'AFKHO', 'Khost', 'AF'),
	(36, 'AFKNR', 'Kunar', 'AF'),
	(37, 'AFLAG', 'Laghman', 'AF'),
	(38, 'AFLOG', 'Logar', 'AF'),
	(39, 'AFNAN', 'Nangarhar', 'AF'),
	(40, 'AFNIM', 'Nimroz', 'AF'),
	(41, 'AFNUR', 'Nuristan', 'AF'),
	(42, 'AFPAN', 'Panjshayr', 'AF'),
	(43, 'AFPAR', 'Parwan', 'AF'),
	(44, 'AFPIA', 'Paktiya', 'AF'),
	(45, 'AFPKA', 'Paktika', 'AF'),
	(46, 'AFSAM', 'Samangan', 'AF'),
	(47, 'AFSAR', 'Sar-e Pul', 'AF'),
	(48, 'AFTAK', 'Takhar', 'AF'),
	(49, 'AFURU', 'Uruzgan', 'AF'),
	(50, 'AFWAR', 'Wardak', 'AF'),
	(51, 'AFZAB', 'Zabul', 'AF'),
	(52, 'AG04', 'Saint John', 'AG'),
	(53, 'AG05', 'Saint Mary', 'AG'),
	(54, 'AG06', 'Saint Paul', 'AG'),
	(55, NULL, 'Anguilla', 'AI'),
	(56, 'AL01', 'Berat', 'AL'),
	(57, 'AL02', 'Durres', 'AL'),
	(58, 'AL03', 'Elbasan', 'AL'),
	(59, 'AL04', 'Fier', 'AL'),
	(60, 'AL05', 'Gjirokaster', 'AL'),
	(61, 'AL06', 'Korce', 'AL'),
	(62, 'AL07', 'Kukes', 'AL'),
	(63, 'AL08', 'Lezhe', 'AL'),
	(64, 'AL09', 'Diber', 'AL'),
	(65, 'AL10', 'Shkoder', 'AL'),
	(66, 'AL11', 'Tirane', 'AL'),
	(67, 'AL12', 'Vlore', 'AL'),
	(68, 'AMAG', 'Aragacotn', 'AM'),
	(69, 'AMAR', 'Ararat', 'AM'),
	(70, 'AMAV', 'Armavir', 'AM'),
	(71, 'AMER', 'Erevan', 'AM'),
	(72, 'AMGR', 'Gegarkunik', 'AM'),
	(73, 'AMKT', 'Kotayk', 'AM'),
	(74, 'AMLO', 'Lori', 'AM'),
	(75, 'AMSH', 'Sirak', 'AM'),
	(76, 'AMSU', 'Syunik', 'AM'),
	(77, 'AMTV', 'Tavus', 'AM'),
	(78, 'AMVD', 'Vayoc Jor', 'AM'),
	(79, 'AOBGO', 'Bengo', 'AO'),
	(80, 'AOBGU', 'Benguela', 'AO'),
	(81, 'AOBIE', 'Bie', 'AO'),
	(82, 'AOCAB', 'Cabinda', 'AO'),
	(83, 'AOCCU', 'Kuando Kubango', 'AO'),
	(84, 'AOCNN', 'Cunene', 'AO'),
	(85, 'AOCNO', 'Kwanza Norte', 'AO'),
	(86, 'AOCUS', 'Kwanza Sul', 'AO'),
	(87, 'AOHUA', 'Huambo', 'AO'),
	(88, 'AOHUI', 'Huila', 'AO'),
	(89, 'AOLNO', 'Lunda Norte', 'AO'),
	(90, 'AOLSU', 'Lunda Sul', 'AO'),
	(91, 'AOLUA', 'Luanda', 'AO'),
	(92, 'AOMAL', 'Malange', 'AO'),
	(93, 'AOMOX', 'Moxico', 'AO'),
	(94, 'AONAM', 'Namibe', 'AO'),
	(95, 'AOUIG', 'Uige', 'AO'),
	(96, 'AOZAI', 'Zaire', 'AO'),
	(97, NULL, 'Antarctica', 'AQ'),
	(98, 'ARA', 'Salta', 'AR'),
	(99, 'ARB', 'Buenos Aires', 'AR'),
	(100, 'ARC', 'Ciudad Autonoma de Buenos Aires', 'AR'),
	(101, 'ARD', 'San Luis', 'AR'),
	(102, 'ARE', 'Entre Rios', 'AR'),
	(103, 'ARF', 'La Rioja', 'AR'),
	(104, 'ARG', 'Santiago del Estero', 'AR'),
	(105, 'ARH', 'Chaco', 'AR'),
	(106, 'ARJ', 'San Juan', 'AR'),
	(107, 'ARK', 'Catamarca', 'AR'),
	(108, 'ARL', 'La Pampa', 'AR'),
	(109, 'ARM', 'Mendoza', 'AR'),
	(110, 'ARN', 'Misiones', 'AR'),
	(111, 'ARP', 'Formosa', 'AR'),
	(112, 'ARQ', 'Neuquen', 'AR'),
	(113, 'ARR', 'Rio Negro', 'AR'),
	(114, 'ARS', 'Santa Fe', 'AR'),
	(115, 'ART', 'Tucuman', 'AR'),
	(116, 'ARU', 'Chubut', 'AR'),
	(117, 'ARV', 'Tierra del Fuego', 'AR'),
	(118, 'ARW', 'Corrientes', 'AR'),
	(119, 'ARX', 'Cordoba', 'AR'),
	(120, 'ARY', 'Jujuy', 'AR'),
	(121, 'ARZ', 'Santa Cruz', 'AR'),
	(122, NULL, 'Eastern District', 'AS'),
	(123, NULL, 'Western District', 'AS'),
	(124, 'AT1', 'Burgenland', 'AT'),
	(125, 'AT2', 'Karnten', 'AT'),
	(126, 'AT3', 'Niederosterreich', 'AT'),
	(127, 'AT4', 'Oberosterreich', 'AT'),
	(128, 'AT5', 'Salzburg', 'AT'),
	(129, 'AT6', 'Steiermark', 'AT'),
	(130, 'AT7', 'Tirol', 'AT'),
	(131, 'AT8', 'Vorarlberg', 'AT'),
	(132, 'AT9', 'Wien', 'AT'),
	(133, 'AUACT', 'Australian Capital Territory', 'AU'),
	(134, 'AUNSW', 'New South Wales', 'AU'),
	(135, 'AUNT', 'Northern Territory', 'AU'),
	(136, 'AUQLD', 'Queensland', 'AU'),
	(137, 'AUSA', 'South Australia', 'AU'),
	(138, 'AUTAS', 'Tasmania', 'AU'),
	(139, 'AUVIC', 'Victoria', 'AU'),
	(140, 'AUWA', 'Western Australia', 'AU'),
	(141, NULL, 'Aruba (general)', 'AW'),
	(142, NULL, 'Eckeroe', 'AX'),
	(143, NULL, 'Finstroem', 'AX'),
	(144, NULL, 'Hammarland', 'AX'),
	(145, NULL, 'Jomala', 'AX'),
	(146, NULL, 'Lemland', 'AX'),
	(147, NULL, 'Mariehamn', 'AX'),
	(148, NULL, 'Saltvik', 'AX'),
	(149, NULL, 'Sund', 'AX'),
	(150, 'AZABS', 'Abseron', 'AZ'),
	(151, 'AZAGA', 'Agstafa', 'AZ'),
	(152, 'AZAGC', 'Agcabadi', 'AZ'),
	(153, 'AZAGM', 'Agdam', 'AZ'),
	(154, 'AZAGS', 'Agdas', 'AZ'),
	(155, 'AZAGU', 'Agsu', 'AZ'),
	(156, 'AZAST', 'Astara', 'AZ'),
	(157, 'AZBA', 'Baki', 'AZ'),
	(158, 'AZBAL', 'Balakan', 'AZ'),
	(159, 'AZBAR', 'Barda', 'AZ'),
	(160, 'AZBEY', 'Beylaqan', 'AZ'),
	(161, 'AZBIL', 'Bilasuvar', 'AZ'),
	(162, 'AZCAB', 'Cabrayil', 'AZ'),
	(163, 'AZCAL', 'Calilabad', 'AZ'),
	(164, 'AZDAS', 'Daskasan', 'AZ'),
	(165, 'AZFUZ', 'Fuzuli', 'AZ'),
	(166, 'AZGA', 'Ganca', 'AZ'),
	(167, 'AZGAD', 'Gadabay', 'AZ'),
	(168, 'AZGOR', 'Goranboy', 'AZ'),
	(169, 'AZGOY', 'Goycay', 'AZ'),
	(170, 'AZGYG', 'Goygol', 'AZ'),
	(171, 'AZHAC', 'Haciqabul', 'AZ'),
	(172, 'AZIMI', 'Imisli', 'AZ'),
	(173, 'AZISM', 'Ismayilli', 'AZ'),
	(174, 'AZKAL', 'Kalbacar', 'AZ'),
	(175, 'AZLA', 'Lankaran', 'AZ'),
	(176, 'AZLAC', 'Lacin', 'AZ'),
	(177, 'AZLER', 'Lerik', 'AZ'),
	(178, 'AZMAS', 'Masalli', 'AZ'),
	(179, 'AZMI', 'Mingacevir', 'AZ'),
	(180, 'AZNA', 'Naftalan', 'AZ'),
	(181, 'AZNEF', 'Neftcala', 'AZ'),
	(182, 'AZNX', 'Naxcivan', 'AZ'),
	(183, 'AZOGU', 'Oguz', 'AZ'),
	(184, 'AZQAB', 'Qabala', 'AZ'),
	(185, 'AZQAX', 'Qax', 'AZ'),
	(186, 'AZQAZ', 'Qazax', 'AZ'),
	(187, 'AZQBA', 'Quba', 'AZ'),
	(188, 'AZQBI', 'Qubadli', 'AZ'),
	(189, 'AZQOB', 'Qobustan', 'AZ'),
	(190, 'AZQUS', 'Qusar', 'AZ'),
	(191, 'AZSA', 'Saki', 'AZ'),
	(192, 'AZSAB', 'Sabirabad', 'AZ'),
	(193, 'AZSAL', 'Salyan', 'AZ'),
	(194, 'AZSAT', 'Saatli', 'AZ'),
	(195, 'AZSKR', 'Samkir', 'AZ'),
	(196, 'AZSM', 'Sumqayit', 'AZ'),
	(197, 'AZSMI', 'Samaxi', 'AZ'),
	(198, 'AZSMX', 'Samux', 'AZ'),
	(199, 'AZSR', 'Sirvan', 'AZ'),
	(200, 'AZSUS', 'Susa', 'AZ'),
	(201, 'AZTAR', 'Tartar', 'AZ'),
	(202, 'AZTOV', 'Tovuz', 'AZ'),
	(203, 'AZUCA', 'Ucar', 'AZ'),
	(204, 'AZXA', 'Xankandi', 'AZ'),
	(205, 'AZXAC', 'Xacmaz', 'AZ'),
	(206, 'AZXCI', 'Xocali', 'AZ'),
	(207, 'AZXIZ', 'Xizi', 'AZ'),
	(208, 'AZXVD', 'Xocavand', 'AZ'),
	(209, 'AZYAR', 'Yardimli', 'AZ'),
	(210, 'AZYE', 'Yevlax', 'AZ'),
	(211, 'AZZAN', 'Zangilan', 'AZ'),
	(212, 'AZZAQ', 'Zaqatala', 'AZ'),
	(213, 'AZZAR', 'Zardab', 'AZ'),
	(214, 'BABIH', 'Federacija Bosne i Hercegovine', 'BA'),
	(215, 'BASRP', 'Republika Srpska', 'BA'),
	(216, 'BB01', 'Christ Church', 'BB'),
	(217, 'BB04', 'Saint James', 'BB'),
	(218, 'BB06', 'Saint Joseph', 'BB'),
	(219, 'BB08', 'Saint Michael', 'BB'),
	(220, 'BB09', 'Saint Peter', 'BB'),
	(221, 'BD06', 'Barisal', 'BD'),
	(222, 'BD10', 'Chittagong', 'BD'),
	(223, 'BD13', 'Dhaka', 'BD'),
	(224, 'BD27', 'Khulna', 'BD'),
	(225, 'BD54', 'Rajshahi', 'BD'),
	(226, 'BD55', 'Rangpur', 'BD'),
	(227, 'BD60', 'Sylhet', 'BD'),
	(228, 'BEBRU', 'Brussels Hoofdstedelijk Gewest', 'BE'),
	(229, 'BEVAN', 'Antwerpen', 'BE'),
	(230, 'BEVBR', 'Vlaams-Brabant', 'BE'),
	(231, 'BEVLI', 'Limburg', 'BE'),
	(232, 'BEVOV', 'Oost-Vlaanderen', 'BE'),
	(233, 'BEVWV', 'West-Vlaanderen', 'BE'),
	(234, 'BEWBR', 'Brabant wallon', 'BE'),
	(235, 'BEWHT', 'Hainaut', 'BE'),
	(236, 'BEWLG', 'Liege', 'BE'),
	(237, 'BEWLX', 'Luxembourg', 'BE'),
	(238, 'BEWNA', 'Namur', 'BE'),
	(239, 'BFBAL', 'Bale', 'BF'),
	(240, 'BFBAM', 'Bam', 'BF'),
	(241, 'BFBAN', 'Banwa', 'BF'),
	(242, 'BFBAZ', 'Bazega', 'BF'),
	(243, 'BFBGR', 'Bougouriba', 'BF'),
	(244, 'BFBLG', 'Boulgou', 'BF'),
	(245, 'BFBLK', 'Boulkiemde', 'BF'),
	(246, 'BFCOM', 'Comoe', 'BF'),
	(247, 'BFGAN', 'Ganzourgou', 'BF'),
	(248, 'BFGNA', 'Gnagna', 'BF'),
	(249, 'BFGOU', 'Gourma', 'BF'),
	(250, 'BFHOU', 'Houet', 'BF');
INSERT INTO public.sehir VALUES
	(251, 'BFIOB', 'Ioba', 'BF'),
	(252, 'BFKAD', 'Kadiogo', 'BF'),
	(253, 'BFKEN', 'Kenedougou', 'BF'),
	(254, 'BFKMD', 'Komondjari', 'BF'),
	(255, 'BFKMP', 'Kompienga', 'BF'),
	(256, 'BFKOP', 'Koulpelogo', 'BF'),
	(257, 'BFKOS', 'Kossi', 'BF'),
	(258, 'BFKOT', 'Kouritenga', 'BF'),
	(259, 'BFKOW', 'Kourweogo', 'BF'),
	(260, 'BFLER', 'Leraba', 'BF'),
	(261, 'BFLOR', 'Loroum', 'BF'),
	(262, 'BFMOU', 'Mouhoun', 'BF'),
	(263, 'BFNAM', 'Namentenga', 'BF'),
	(264, 'BFNAO', 'Nahouri', 'BF'),
	(265, 'BFNAY', 'Nayala', 'BF'),
	(266, 'BFNOU', 'Noumbiel', 'BF'),
	(267, 'BFOUB', 'Oubritenga', 'BF'),
	(268, 'BFOUD', 'Oudalan', 'BF'),
	(269, 'BFPAS', 'Passore', 'BF'),
	(270, 'BFPON', 'Poni', 'BF'),
	(271, 'BFSEN', 'Seno', 'BF'),
	(272, 'BFSIS', 'Sissili', 'BF'),
	(273, 'BFSMT', 'Sanmatenga', 'BF'),
	(274, 'BFSNG', 'Sanguie', 'BF'),
	(275, 'BFSOM', 'Soum', 'BF'),
	(276, 'BFSOR', 'Sourou', 'BF'),
	(277, 'BFTAP', 'Tapoa', 'BF'),
	(278, 'BFTUI', 'Tuy', 'BF'),
	(279, 'BFYAG', 'Yagha', 'BF'),
	(280, 'BFYAT', 'Yatenga', 'BF'),
	(281, 'BFZIR', 'Ziro', 'BF'),
	(282, 'BFZON', 'Zondoma', 'BF'),
	(283, 'BFZOU', 'Zoundweogo', 'BF'),
	(284, 'BG01', 'Blagoevgrad', 'BG'),
	(285, 'BG02', 'Burgas', 'BG'),
	(286, 'BG03', 'Varna', 'BG'),
	(287, 'BG04', 'Veliko Tarnovo', 'BG'),
	(288, 'BG05', 'Vidin', 'BG'),
	(289, 'BG06', 'Vratsa', 'BG'),
	(290, 'BG07', 'Gabrovo', 'BG'),
	(291, 'BG08', 'Dobrich', 'BG'),
	(292, 'BG09', 'Kardzhali', 'BG'),
	(293, 'BG10', 'Kyustendil', 'BG'),
	(294, 'BG11', 'Lovech', 'BG'),
	(295, 'BG12', 'Montana', 'BG'),
	(296, 'BG13', 'Pazardzhik', 'BG'),
	(297, 'BG14', 'Pernik', 'BG'),
	(298, 'BG15', 'Pleven', 'BG'),
	(299, 'BG16', 'Plovdiv', 'BG'),
	(300, 'BG17', 'Razgrad', 'BG'),
	(301, 'BG18', 'Ruse', 'BG'),
	(302, 'BG19', 'Silistra', 'BG'),
	(303, 'BG20', 'Sliven', 'BG'),
	(304, 'BG21', 'Smolyan', 'BG'),
	(305, 'BG22', 'Sofia (stolitsa)', 'BG'),
	(306, 'BG23', 'Sofia', 'BG'),
	(307, 'BG24', 'Stara Zagora', 'BG'),
	(308, 'BG25', 'Targovishte', 'BG'),
	(309, 'BG26', 'Haskovo', 'BG'),
	(310, 'BG27', 'Shumen', 'BG'),
	(311, 'BG28', 'Yambol', 'BG'),
	(312, 'BH13', 'Al Asimah', 'BH'),
	(313, 'BH15', 'Al Muharraq', 'BH'),
	(314, 'BH17', 'Ash Shamaliyah', 'BH'),
	(315, 'BIBB', 'Bubanza', 'BI'),
	(316, 'BIBM', 'Bujumbura Mairie', 'BI'),
	(317, 'BIBR', 'Bururi', 'BI'),
	(318, 'BICA', 'Cankuzo', 'BI'),
	(319, 'BICI', 'Cibitoke', 'BI'),
	(320, 'BIGI', 'Gitega', 'BI'),
	(321, 'BIKI', 'Kirundo', 'BI'),
	(322, 'BIKR', 'Karuzi', 'BI'),
	(323, 'BIKY', 'Kayanza', 'BI'),
	(324, 'BIMA', 'Makamba', 'BI'),
	(325, 'BIMU', 'Muramvya', 'BI'),
	(326, 'BIMW', 'Mwaro', 'BI'),
	(327, 'BIMY', 'Muyinga', 'BI'),
	(328, 'BING', 'Ngozi', 'BI'),
	(329, 'BIRT', 'Rutana', 'BI'),
	(330, 'BIRY', 'Ruyigi', 'BI'),
	(331, 'BJAK', 'Atacora', 'BJ'),
	(332, 'BJAL', 'Alibori', 'BJ'),
	(333, 'BJAQ', 'Atlantique', 'BJ'),
	(334, 'BJBO', 'Borgou', 'BJ'),
	(335, 'BJCO', 'Collines', 'BJ'),
	(336, 'BJDO', 'Donga', 'BJ'),
	(337, 'BJKO', 'Couffo', 'BJ'),
	(338, 'BJLI', 'Littoral', 'BJ'),
	(339, 'BJMO', 'Mono', 'BJ'),
	(340, 'BJOU', 'Oueme', 'BJ'),
	(341, 'BJPL', 'Plateau', 'BJ'),
	(342, 'BJZO', 'Zou', 'BJ'),
	(343, NULL, 'Saint Barthelemy', 'BL'),
	(344, NULL, 'Hamilton', 'BM'),
	(345, NULL, 'Saint George', 'BM'),
	(346, 'BNBE', 'Belait', 'BN'),
	(347, 'BNBM', 'Brunei-Muara', 'BN'),
	(348, 'BNTE', 'Temburong', 'BN'),
	(349, 'BNTU', 'Tutong', 'BN'),
	(350, 'BOB', 'El Beni', 'BO'),
	(351, 'BOC', 'Cochabamba', 'BO'),
	(352, 'BOH', 'Chuquisaca', 'BO'),
	(353, 'BOL', 'La Paz', 'BO'),
	(354, 'BON', 'Pando', 'BO'),
	(355, 'BOO', 'Oruro', 'BO'),
	(356, 'BOP', 'Potosi', 'BO'),
	(357, 'BOS', 'Santa Cruz', 'BO'),
	(358, 'BOT', 'Tarija', 'BO'),
	(359, 'BQBO', 'Bonaire', 'BQ'),
	(360, 'BQSA', 'Saba', 'BQ'),
	(361, 'BQSE', 'Sint Eustatius', 'BQ'),
	(362, 'BRAC', 'Acre', 'BR'),
	(363, 'BRAL', 'Alagoas', 'BR'),
	(364, 'BRAM', 'Amazonas', 'BR'),
	(365, 'BRAP', 'Amapa', 'BR'),
	(366, 'BRBA', 'Bahia', 'BR'),
	(367, 'BRCE', 'Ceara', 'BR'),
	(368, 'BRDF', 'Distrito Federal', 'BR'),
	(369, 'BRES', 'Espirito Santo', 'BR'),
	(370, 'BRGO', 'Goias', 'BR'),
	(371, 'BRMA', 'Maranhao', 'BR'),
	(372, 'BRMG', 'Minas Gerais', 'BR'),
	(373, 'BRMS', 'Mato Grosso do Sul', 'BR'),
	(374, 'BRMT', 'Mato Grosso', 'BR'),
	(375, 'BRPA', 'Para', 'BR'),
	(376, 'BRPB', 'Paraiba', 'BR'),
	(377, 'BRPE', 'Pernambuco', 'BR'),
	(378, 'BRPI', 'Piaui', 'BR'),
	(379, 'BRPR', 'Parana', 'BR'),
	(380, 'BRRJ', 'Rio de Janeiro', 'BR'),
	(381, 'BRRN', 'Rio Grande do Norte', 'BR'),
	(382, 'BRRO', 'Rondonia', 'BR'),
	(383, 'BRRR', 'Roraima', 'BR'),
	(384, 'BRRS', 'Rio Grande do Sul', 'BR'),
	(385, 'BRSC', 'Santa Catarina', 'BR'),
	(386, 'BRSE', 'Sergipe', 'BR'),
	(387, 'BRSP', 'Sao Paulo', 'BR'),
	(388, 'BRTO', 'Tocantins', 'BR'),
	(389, NULL, 'New Providence', 'BS'),
	(390, 'BSCS', 'Central Andros', 'BS'),
	(391, 'BSEG', 'East Grand Bahama', 'BS'),
	(392, 'BSFP', 'City of Freeport', 'BS'),
	(393, 'BSHI', 'Harbour Island', 'BS'),
	(394, 'BSHT', 'Hope Town', 'BS'),
	(395, 'BSLI', 'Long Island', 'BS'),
	(396, 'BSSE', 'South Eleuthera', 'BS'),
	(397, 'BT11', 'Paro', 'BT'),
	(398, 'BT12', 'Chhukha', 'BT'),
	(399, 'BT13', 'Haa', 'BT'),
	(400, 'BT15', 'Thimphu', 'BT'),
	(401, 'BT22', 'Dagana', 'BT'),
	(402, 'BT23', 'Punakha', 'BT'),
	(403, 'BT32', 'Trongsa', 'BT'),
	(404, 'BT34', 'Zhemgang', 'BT'),
	(405, 'BT42', 'Monggar', 'BT'),
	(406, 'BTGA', 'Gasa', 'BT'),
	(407, 'BTTY', 'Trashi Yangtse', 'BT'),
	(408, 'BWCE', 'Central', 'BW'),
	(409, 'BWGH', 'Ghanzi', 'BW'),
	(410, 'BWKG', 'Kgalagadi', 'BW'),
	(411, 'BWKL', 'Kgatleng', 'BW'),
	(412, 'BWKW', 'Kweneng', 'BW'),
	(413, 'BWNE', 'North East', 'BW'),
	(414, 'BWNW', 'North West', 'BW'),
	(415, 'BWSE', 'South East', 'BW'),
	(416, 'BWSO', 'Southern', 'BW'),
	(417, 'BYBR', 'Brestskaya voblasts', 'BY'),
	(418, 'BYHO', 'Homyelskaya voblasts', 'BY'),
	(419, 'BYHR', 'Hrodzenskaya voblasts', 'BY'),
	(420, 'BYMA', 'Mahilyowskaya voblasts', 'BY'),
	(421, 'BYMI', 'Minskaya voblasts', 'BY'),
	(422, 'BYVI', 'Vitsyebskaya voblasts', 'BY'),
	(423, 'BZBZ', 'Belize', 'BZ'),
	(424, 'BZCY', 'Cayo', 'BZ'),
	(425, 'BZCZL', 'Corozal', 'BZ'),
	(426, 'BZOW', 'Orange Walk', 'BZ'),
	(427, 'BZSC', 'Stann Creek', 'BZ'),
	(428, 'BZTOL', 'Toledo', 'BZ'),
	(429, 'CAAB', 'Alberta', 'CA'),
	(430, 'CABC', 'British Columbia', 'CA'),
	(431, 'CAMB', 'Manitoba', 'CA'),
	(432, 'CANB', 'New Brunswick', 'CA'),
	(433, 'CANL', 'Newfoundland and Labrador', 'CA'),
	(434, 'CANS', 'Nova Scotia', 'CA'),
	(435, 'CANT', 'Northwest Territories', 'CA'),
	(436, 'CANU', 'Nunavut', 'CA'),
	(437, 'CAON', 'Ontario', 'CA'),
	(438, 'CAPE', 'Prince Edward Island', 'CA'),
	(439, 'CAQC', 'Quebec', 'CA'),
	(440, 'CASK', 'Saskatchewan', 'CA'),
	(441, 'CAYT', 'Yukon', 'CA'),
	(442, NULL, 'Cocos Islands and Keeling Islands', 'CC'),
	(443, 'CDBC', 'Kongo Central', 'CD'),
	(444, 'CDBU', 'Bas-Uele', 'CD'),
	(445, 'CDEQ', 'Equateur', 'CD'),
	(446, 'CDHK', 'Haut-Katanga', 'CD'),
	(447, 'CDHL', 'Haut-Lomani', 'CD'),
	(448, 'CDHU', 'Haut-Uele', 'CD'),
	(449, 'CDIT', 'Ituri', 'CD'),
	(450, 'CDKC', 'Kasai Central', 'CD'),
	(451, 'CDKE', 'Kasai Oriental', 'CD'),
	(452, 'CDKG', 'Kwango', 'CD'),
	(453, 'CDKL', 'Kwilu', 'CD'),
	(454, 'CDKN', 'Kinshasa', 'CD'),
	(455, 'CDKS', 'Kasai', 'CD'),
	(456, 'CDLO', 'Lomami', 'CD'),
	(457, 'CDLU', 'Lualaba', 'CD'),
	(458, 'CDMA', 'Maniema', 'CD'),
	(459, 'CDMN', 'Mai-Ndombe', 'CD'),
	(460, 'CDMO', 'Mongala', 'CD'),
	(461, 'CDNK', 'Nord-Kivu', 'CD'),
	(462, 'CDNU', 'Nord-Ubangi', 'CD'),
	(463, 'CDSA', 'Sankuru', 'CD'),
	(464, 'CDSK', 'Sud-Kivu', 'CD'),
	(465, 'CDSU', 'Sud-Ubangi', 'CD'),
	(466, 'CDTA', 'Tanganyika', 'CD'),
	(467, 'CDTO', 'Tshopo', 'CD'),
	(468, 'CDTU', 'Tshuapa', 'CD'),
	(469, 'CFAC', 'Ouham', 'CF'),
	(470, 'CFBB', 'Bamingui-Bangoran', 'CF'),
	(471, 'CFBGF', 'Bangui', 'CF'),
	(472, 'CFBK', 'Basse-Kotto', 'CF'),
	(473, 'CFHK', 'Haute-Kotto', 'CF'),
	(474, 'CFHM', 'Haut-Mbomou', 'CF'),
	(475, 'CFHS', 'Mambere-Kadei', 'CF'),
	(476, 'CFKB', 'Gribingui', 'CF'),
	(477, 'CFKG', 'Kemo-Gribingui', 'CF'),
	(478, 'CFLB', 'Lobaye', 'CF'),
	(479, 'CFMB', 'Mbomou', 'CF'),
	(480, 'CFMP', 'Ombella-Mpoko', 'CF'),
	(481, 'CFNM', 'Nana-Mambere', 'CF'),
	(482, 'CFOP', 'Ouham-Pende', 'CF'),
	(483, 'CFSE', 'Sangha', 'CF'),
	(484, 'CFUK', 'Ouaka', 'CF'),
	(485, 'CG11', 'Bouenza', 'CG'),
	(486, 'CG12', 'Pool', 'CG'),
	(487, 'CG13', 'Sangha', 'CG'),
	(488, 'CG14', 'Plateaux', 'CG'),
	(489, 'CG15', 'Cuvette-Ouest', 'CG'),
	(490, 'CG16', 'Pointe-Noire', 'CG'),
	(491, 'CG2', 'Lekoumou', 'CG'),
	(492, 'CG7', 'Likouala', 'CG'),
	(493, 'CG8', 'Cuvette', 'CG'),
	(494, 'CG9', 'Niari', 'CG'),
	(495, 'CGBZV', 'Brazzaville', 'CG'),
	(496, 'CHAG', 'Aargau', 'CH'),
	(497, 'CHAI', 'Appenzell Innerrhoden', 'CH'),
	(498, 'CHAR', 'Appenzell Ausserrhoden', 'CH'),
	(499, 'CHBE', 'Bern', 'CH'),
	(500, 'CHBL', 'Basel-Landschaft', 'CH');
INSERT INTO public.sehir VALUES
	(501, 'CHBS', 'Basel-Stadt', 'CH'),
	(502, 'CHFR', 'Fribourg', 'CH'),
	(503, 'CHGE', 'Geneve', 'CH'),
	(504, 'CHGL', 'Glarus', 'CH'),
	(505, 'CHGR', 'Graubunden', 'CH'),
	(506, 'CHJU', 'Jura', 'CH'),
	(507, 'CHLU', 'Luzern', 'CH'),
	(508, 'CHNE', 'Neuchatel', 'CH'),
	(509, 'CHNW', 'Nidwalden', 'CH'),
	(510, 'CHOW', 'Obwalden', 'CH'),
	(511, 'CHSG', 'Sankt Gallen', 'CH'),
	(512, 'CHSH', 'Schaffhausen', 'CH'),
	(513, 'CHSO', 'Solothurn', 'CH'),
	(514, 'CHSZ', 'Schwyz', 'CH'),
	(515, 'CHTG', 'Thurgau', 'CH'),
	(516, 'CHTI', 'Ticino', 'CH'),
	(517, 'CHUR', 'Uri', 'CH'),
	(518, 'CHVD', 'Vaud', 'CH'),
	(519, 'CHVS', 'Valais', 'CH'),
	(520, 'CHZG', 'Zug', 'CH'),
	(521, 'CHZH', 'Zurich', 'CH'),
	(522, 'CIAB', 'Abidjan', 'CI'),
	(523, 'CIBS', 'Bas-Sassandra', 'CI'),
	(524, 'CICM', 'Comoe', 'CI'),
	(525, 'CIDN', 'Denguele', 'CI'),
	(526, 'CIGD', 'Goh-Djiboua', 'CI'),
	(527, 'CILC', 'Lacs', 'CI'),
	(528, 'CILG', 'Lagunes', 'CI'),
	(529, 'CIMG', 'Montagnes', 'CI'),
	(530, 'CISM', 'Sassandra-Marahoue', 'CI'),
	(531, 'CISV', 'Savanes', 'CI'),
	(532, 'CIVB', 'Vallee du Bandama', 'CI'),
	(533, 'CIWR', 'Woroba', 'CI'),
	(534, 'CIZZ', 'Zanzan', 'CI'),
	(535, NULL, 'Cook Islands', 'CK'),
	(536, 'CLAI', 'Aisen del General Carlos Ibanez del Campo', 'CL'),
	(537, 'CLAN', 'Antofagasta', 'CL'),
	(538, 'CLAP', 'Arica y Parinacota', 'CL'),
	(539, 'CLAR', 'La Araucania', 'CL'),
	(540, 'CLAT', 'Atacama', 'CL'),
	(541, 'CLBI', 'Biobio', 'CL'),
	(542, 'CLCO', 'Coquimbo', 'CL'),
	(543, 'CLLI', 'Libertador General Bernardo OHiggins', 'CL'),
	(544, 'CLLL', 'Los Lagos', 'CL'),
	(545, 'CLLR', 'Los Rios', 'CL'),
	(546, 'CLMA', 'Magallanes', 'CL'),
	(547, 'CLML', 'Maule', 'CL'),
	(548, 'CLRM', 'Region Metropolitana de Santiago', 'CL'),
	(549, 'CLTA', 'Tarapaca', 'CL'),
	(550, 'CLVS', 'Valparaiso', 'CL'),
	(551, 'CMAD', 'Adamaoua', 'CM'),
	(552, 'CMCE', 'Centre', 'CM'),
	(553, 'CMEN', 'Extreme-Nord', 'CM'),
	(554, 'CMES', 'Est', 'CM'),
	(555, 'CMLT', 'Littoral', 'CM'),
	(556, 'CMNO', 'Nord', 'CM'),
	(557, 'CMNW', 'Nord-Ouest', 'CM'),
	(558, 'CMOU', 'Ouest', 'CM'),
	(559, 'CMSU', 'Sud', 'CM'),
	(560, 'CMSW', 'Sud-Ouest', 'CM'),
	(561, 'CN11', 'Beijing', 'CN'),
	(562, 'CN12', 'Tianjin', 'CN'),
	(563, 'CN13', 'Hebei', 'CN'),
	(564, 'CN14', 'Shanxi', 'CN'),
	(565, 'CN15', 'Nei Mongol', 'CN'),
	(566, 'CN21', 'Liaoning', 'CN'),
	(567, 'CN22', 'Jilin', 'CN'),
	(568, 'CN23', 'Heilongjiang', 'CN'),
	(569, 'CN31', 'Shanghai', 'CN'),
	(570, 'CN32', 'Jiangsu', 'CN'),
	(571, 'CN33', 'Zhejiang', 'CN'),
	(572, 'CN34', 'Anhui', 'CN'),
	(573, 'CN35', 'Fujian', 'CN'),
	(574, 'CN36', 'Jiangxi', 'CN'),
	(575, 'CN37', 'Shandong', 'CN'),
	(576, 'CN41', 'Henan', 'CN'),
	(577, 'CN42', 'Hubei', 'CN'),
	(578, 'CN43', 'Hunan', 'CN'),
	(579, 'CN44', 'Guangdong', 'CN'),
	(580, 'CN45', 'Guangxi', 'CN'),
	(581, 'CN46', 'Hainan', 'CN'),
	(582, 'CN50', 'Chongqing', 'CN'),
	(583, 'CN51', 'Sichuan', 'CN'),
	(584, 'CN52', 'Guizhou', 'CN'),
	(585, 'CN53', 'Yunnan', 'CN'),
	(586, 'CN54', 'Xizang', 'CN'),
	(587, 'CN61', 'Shaanxi', 'CN'),
	(588, 'CN62', 'Gansu', 'CN'),
	(589, 'CN63', 'Qinghai', 'CN'),
	(590, 'CN64', 'Ningxia', 'CN'),
	(591, 'CN65', 'Xinjiang', 'CN'),
	(592, 'COAMA', 'Amazonas', 'CO'),
	(593, 'COANT', 'Antioquia', 'CO'),
	(594, 'COARA', 'Arauca', 'CO'),
	(595, 'COATL', 'Atlantico', 'CO'),
	(596, 'COBOL', 'Bolivar', 'CO'),
	(597, 'COBOY', 'Boyaca', 'CO'),
	(598, 'COCAL', 'Caldas', 'CO'),
	(599, 'COCAQ', 'Caqueta', 'CO'),
	(600, 'COCAS', 'Casanare', 'CO'),
	(601, 'COCAU', 'Cauca', 'CO'),
	(602, 'COCES', 'Cesar', 'CO'),
	(603, 'COCHO', 'Choco', 'CO'),
	(604, 'COCOR', 'Cordoba', 'CO'),
	(605, 'COCUN', 'Cundinamarca', 'CO'),
	(606, 'CODC', 'Distrito Capital de Bogota', 'CO'),
	(607, 'COGUA', 'Guainia', 'CO'),
	(608, 'COGUV', 'Guaviare', 'CO'),
	(609, 'COHUI', 'Huila', 'CO'),
	(610, 'COLAG', 'La Guajira', 'CO'),
	(611, 'COMAG', 'Magdalena', 'CO'),
	(612, 'COMET', 'Meta', 'CO'),
	(613, 'CONAR', 'Narino', 'CO'),
	(614, 'CONSA', 'Norte de Santander', 'CO'),
	(615, 'COPUT', 'Putumayo', 'CO'),
	(616, 'COQUI', 'Quindio', 'CO'),
	(617, 'CORIS', 'Risaralda', 'CO'),
	(618, 'COSAN', 'Santander', 'CO'),
	(619, 'COSAP', 'San Andres, Providencia y Santa Catalina', 'CO'),
	(620, 'COSUC', 'Sucre', 'CO'),
	(621, 'COTOL', 'Tolima', 'CO'),
	(622, 'COVAC', 'Valle del Cauca', 'CO'),
	(623, 'COVAU', 'Vaupes', 'CO'),
	(624, 'COVID', 'Vichada', 'CO'),
	(625, 'CRA', 'Alajuela', 'CR'),
	(626, 'CRC', 'Cartago', 'CR'),
	(627, 'CRG', 'Guanacaste', 'CR'),
	(628, 'CRH', 'Heredia', 'CR'),
	(629, 'CRL', 'Limon', 'CR'),
	(630, 'CRP', 'Puntarenas', 'CR'),
	(631, 'CRSJ', 'San Jose', 'CR'),
	(632, 'CU01', 'Pinar del Rio', 'CU'),
	(633, 'CU03', 'La Habana', 'CU'),
	(634, 'CU04', 'Matanzas', 'CU'),
	(635, 'CU05', 'Villa Clara', 'CU'),
	(636, 'CU06', 'Cienfuegos', 'CU'),
	(637, 'CU07', 'Sancti Spiritus', 'CU'),
	(638, 'CU08', 'Ciego de Avila', 'CU'),
	(639, 'CU09', 'Camaguey', 'CU'),
	(640, 'CU10', 'Las Tunas', 'CU'),
	(641, 'CU11', 'Holguin', 'CU'),
	(642, 'CU12', 'Granma', 'CU'),
	(643, 'CU13', 'Santiago de Cuba', 'CU'),
	(644, 'CU14', 'Guantanamo', 'CU'),
	(645, 'CU15', 'Artemisa', 'CU'),
	(646, 'CU16', 'Mayabeque', 'CU'),
	(647, 'CU99', 'Isla de la Juventud', 'CU'),
	(648, 'CVBR', 'Brava', 'CV'),
	(649, 'CVBV', 'Boa Vista', 'CV'),
	(650, 'CVCA', 'Santa Catarina', 'CV'),
	(651, 'CVCF', 'Santa Catarina do Fogo', 'CV'),
	(652, 'CVCR', 'Santa Cruz', 'CV'),
	(653, 'CVMA', 'Maio', 'CV'),
	(654, 'CVMO', 'Mosteiros', 'CV'),
	(655, 'CVPA', 'Paul', 'CV'),
	(656, 'CVPN', 'Porto Novo', 'CV'),
	(657, 'CVPR', 'Praia', 'CV'),
	(658, 'CVRB', 'Ribeira Brava', 'CV'),
	(659, 'CVRG', 'Ribeira Grande', 'CV'),
	(660, 'CVRS', 'Ribeira Grande de Santiago', 'CV'),
	(661, 'CVSD', 'Sao Domingos', 'CV'),
	(662, 'CVSF', 'Sao Filipe', 'CV'),
	(663, 'CVSL', 'Sal', 'CV'),
	(664, 'CVSM', 'Sao Miguel', 'CV'),
	(665, 'CVSS', 'Sao Salvador do Mundo', 'CV'),
	(666, 'CVSV', 'Sao Vicente', 'CV'),
	(667, 'CVTA', 'Tarrafal', 'CV'),
	(668, 'CVTS', 'Tarrafal de Sao Nicolau', 'CV'),
	(669, NULL, 'Curacao', 'CW'),
	(670, NULL, 'Christmas Island', 'CX'),
	(671, 'CY01', 'Lefkosia', 'CY'),
	(672, 'CY02', 'Lemesos', 'CY'),
	(673, 'CY03', 'Larnaka', 'CY'),
	(674, 'CY04', 'Ammochostos', 'CY'),
	(675, 'CY05', 'Pafos', 'CY'),
	(676, 'CY06', 'Keryneia', 'CY'),
	(677, 'CZ10', 'Praha, Hlavni mesto', 'CZ'),
	(678, 'CZ63', 'Kraj Vysocina', 'CZ'),
	(679, 'CZJC', 'Jihocesky kraj', 'CZ'),
	(680, 'CZJM', 'Jihomoravsky kraj', 'CZ'),
	(681, 'CZKA', 'Karlovarsky kraj', 'CZ'),
	(682, 'CZKR', 'Kralovehradecky kraj', 'CZ'),
	(683, 'CZLI', 'Liberecky kraj', 'CZ'),
	(684, 'CZMO', 'Moravskoslezsky kraj', 'CZ'),
	(685, 'CZOL', 'Olomoucky kraj', 'CZ'),
	(686, 'CZPA', 'Pardubicky kraj', 'CZ'),
	(687, 'CZPL', 'Plzensky kraj', 'CZ'),
	(688, 'CZST', 'Stredocesky kraj', 'CZ'),
	(689, 'CZUS', 'Ustecky kraj', 'CZ'),
	(690, 'CZZL', 'Zlinsky kraj', 'CZ'),
	(691, 'DEBB', 'Brandenburg', 'DE'),
	(692, 'DEBE', 'Berlin', 'DE'),
	(693, 'DEBW', 'Baden-Wurttemberg', 'DE'),
	(694, 'DEBY', 'Bayern', 'DE'),
	(695, 'DEHB', 'Bremen', 'DE'),
	(696, 'DEHE', 'Hessen', 'DE'),
	(697, 'DEHH', 'Hamburg', 'DE'),
	(698, 'DEMV', 'Mecklenburg-Vorpommern', 'DE'),
	(699, 'DENI', 'Niedersachsen', 'DE'),
	(700, 'DENW', 'Nordrhein-Westfalen', 'DE'),
	(701, 'DERP', 'Rheinland-Pfalz', 'DE'),
	(702, 'DESH', 'Schleswig-Holstein', 'DE'),
	(703, 'DESL', 'Saarland', 'DE'),
	(704, 'DESN', 'Sachsen', 'DE'),
	(705, 'DEST', 'Sachsen-Anhalt', 'DE'),
	(706, 'DETH', 'Thuringen', 'DE'),
	(707, 'DJAR', 'Arta', 'DJ'),
	(708, 'DJAS', 'Ali Sabieh', 'DJ'),
	(709, 'DJDI', 'Dikhil', 'DJ'),
	(710, 'DJDJ', 'Djibouti', 'DJ'),
	(711, 'DJOB', 'Obock', 'DJ'),
	(712, 'DJTA', 'Tadjourah', 'DJ'),
	(713, 'DK81', 'Nordjylland', 'DK'),
	(714, 'DK82', 'Midtjylland', 'DK'),
	(715, 'DK83', 'Syddanmark', 'DK'),
	(716, 'DK84', 'Hovedstaden', 'DK'),
	(717, 'DK85', 'Sjelland', 'DK'),
	(718, 'DM02', 'Saint Andrew', 'DM'),
	(719, 'DM03', 'Saint David', 'DM'),
	(720, 'DM04', 'Saint George', 'DM'),
	(721, 'DM05', 'Saint John', 'DM'),
	(722, 'DM06', 'Saint Joseph', 'DM'),
	(723, 'DM07', 'Saint Luke', 'DM'),
	(724, 'DM08', 'Saint Mark', 'DM'),
	(725, 'DM09', 'Saint Patrick', 'DM'),
	(726, 'DM10', 'Saint Paul', 'DM'),
	(727, 'DO01', 'Distrito Nacional (Santo Domingo)', 'DO'),
	(728, 'DO02', 'Azua', 'DO'),
	(729, 'DO03', 'Baoruco', 'DO'),
	(730, 'DO04', 'Barahona', 'DO'),
	(731, 'DO05', 'Dajabon', 'DO'),
	(732, 'DO06', 'Duarte', 'DO'),
	(733, 'DO07', 'Elias Pina', 'DO'),
	(734, 'DO08', 'El Seibo', 'DO'),
	(735, 'DO09', 'Espaillat', 'DO'),
	(736, 'DO10', 'Independencia', 'DO'),
	(737, 'DO11', 'La Altagracia', 'DO'),
	(738, 'DO12', 'La Romana', 'DO'),
	(739, 'DO13', 'La Vega', 'DO'),
	(740, 'DO14', 'Maria Trinidad Sanchez', 'DO'),
	(741, 'DO15', 'Monte Cristi', 'DO'),
	(742, 'DO16', 'Pedernales', 'DO'),
	(743, 'DO17', 'Peravia', 'DO'),
	(744, 'DO18', 'Puerto Plata', 'DO'),
	(745, 'DO19', 'Hermanas Mirabal', 'DO'),
	(746, 'DO20', 'Samana', 'DO'),
	(747, 'DO21', 'San Cristobal', 'DO'),
	(748, 'DO22', 'San Juan', 'DO'),
	(749, 'DO23', 'San Pedro de Macoris', 'DO'),
	(750, 'DO24', 'Sanchez Ramirez', 'DO');
INSERT INTO public.sehir VALUES
	(751, 'DO25', 'Santiago', 'DO'),
	(752, 'DO26', 'Santiago Rodriguez', 'DO'),
	(753, 'DO27', 'Valverde', 'DO'),
	(754, 'DO28', 'Monsenor Nouel', 'DO'),
	(755, 'DO29', 'Monte Plata', 'DO'),
	(756, 'DO30', 'Hato Mayor', 'DO'),
	(757, 'DZ01', 'Adrar', 'DZ'),
	(758, 'DZ02', 'Chlef', 'DZ'),
	(759, 'DZ03', 'Laghouat', 'DZ'),
	(760, 'DZ04', 'Oum el Bouaghi', 'DZ'),
	(761, 'DZ05', 'Batna', 'DZ'),
	(762, 'DZ06', 'Bejaia', 'DZ'),
	(763, 'DZ07', 'Biskra', 'DZ'),
	(764, 'DZ08', 'Bechar', 'DZ'),
	(765, 'DZ09', 'Blida', 'DZ'),
	(766, 'DZ10', 'Bouira', 'DZ'),
	(767, 'DZ11', 'Tamanrasset', 'DZ'),
	(768, 'DZ12', 'Tebessa', 'DZ'),
	(769, 'DZ13', 'Tlemcen', 'DZ'),
	(770, 'DZ14', 'Tiaret', 'DZ'),
	(771, 'DZ15', 'Tizi Ouzou', 'DZ'),
	(772, 'DZ16', 'Alger', 'DZ'),
	(773, 'DZ17', 'Djelfa', 'DZ'),
	(774, 'DZ19', 'Setif', 'DZ'),
	(775, 'DZ20', 'Saida', 'DZ'),
	(776, 'DZ21', 'Skikda', 'DZ'),
	(777, 'DZ22', 'Sidi Bel Abbes', 'DZ'),
	(778, 'DZ23', 'Annaba', 'DZ'),
	(779, 'DZ24', 'Guelma', 'DZ'),
	(780, 'DZ25', 'Constantine', 'DZ'),
	(781, 'DZ26', 'Medea', 'DZ'),
	(782, 'DZ27', 'Mostaganem', 'DZ'),
	(783, 'DZ28', 'Msila', 'DZ'),
	(784, 'DZ29', 'Mascara', 'DZ'),
	(785, 'DZ30', 'Ouargla', 'DZ'),
	(786, 'DZ31', 'Oran', 'DZ'),
	(787, 'DZ32', 'El Bayadh', 'DZ'),
	(788, 'DZ33', 'Illizi', 'DZ'),
	(789, 'DZ34', 'Bordj Bou Arreridj', 'DZ'),
	(790, 'DZ35', 'Boumerdes', 'DZ'),
	(791, 'DZ36', 'El Tarf', 'DZ'),
	(792, 'DZ37', 'Tindouf', 'DZ'),
	(793, 'DZ38', 'Tissemsilt', 'DZ'),
	(794, 'DZ39', 'El Oued', 'DZ'),
	(795, 'DZ40', 'Khenchela', 'DZ'),
	(796, 'DZ41', 'Souk Ahras', 'DZ'),
	(797, 'DZ42', 'Tipaza', 'DZ'),
	(798, 'DZ43', 'Mila', 'DZ'),
	(799, 'DZ44', 'Ain Defla', 'DZ'),
	(800, 'DZ45', 'Naama', 'DZ'),
	(801, 'DZ46', 'Ain Temouchent', 'DZ'),
	(802, 'DZ47', 'Ghardaia', 'DZ'),
	(803, 'DZ48', 'Relizane', 'DZ'),
	(804, 'ECA', 'Azuay', 'EC'),
	(805, 'ECB', 'Bolivar', 'EC'),
	(806, 'ECC', 'Carchi', 'EC'),
	(807, 'ECD', 'Orellana', 'EC'),
	(808, 'ECE', 'Esmeraldas', 'EC'),
	(809, 'ECF', 'Canar', 'EC'),
	(810, 'ECG', 'Guayas', 'EC'),
	(811, 'ECH', 'Chimborazo', 'EC'),
	(812, 'ECI', 'Imbabura', 'EC'),
	(813, 'ECL', 'Loja', 'EC'),
	(814, 'ECM', 'Manabi', 'EC'),
	(815, 'ECN', 'Napo', 'EC'),
	(816, 'ECO', 'El Oro', 'EC'),
	(817, 'ECP', 'Pichincha', 'EC'),
	(818, 'ECR', 'Los Rios', 'EC'),
	(819, 'ECS', 'Morona-Santiago', 'EC'),
	(820, 'ECSE', 'Santa Elena', 'EC'),
	(821, 'ECT', 'Tungurahua', 'EC'),
	(822, 'ECU', 'Sucumbios', 'EC'),
	(823, 'ECW', 'Galapagos', 'EC'),
	(824, 'ECX', 'Cotopaxi', 'EC'),
	(825, 'ECY', 'Pastaza', 'EC'),
	(826, 'ECZ', 'Zamora-Chinchipe', 'EC'),
	(827, 'EE37', 'Harjumaa', 'EE'),
	(828, 'EE39', 'Hiiumaa', 'EE'),
	(829, 'EE44', 'Ida-Virumaa', 'EE'),
	(830, 'EE49', 'Jogevamaa', 'EE'),
	(831, 'EE51', 'Jarvamaa', 'EE'),
	(832, 'EE57', 'Laanemaa', 'EE'),
	(833, 'EE59', 'Laane-Virumaa', 'EE'),
	(834, 'EE65', 'Polvamaa', 'EE'),
	(835, 'EE67', 'Parnumaa', 'EE'),
	(836, 'EE70', 'Raplamaa', 'EE'),
	(837, 'EE74', 'Saaremaa', 'EE'),
	(838, 'EE78', 'Tartumaa', 'EE'),
	(839, 'EE82', 'Valgamaa', 'EE'),
	(840, 'EE84', 'Viljandimaa', 'EE'),
	(841, 'EE86', 'Vorumaa', 'EE'),
	(842, 'EGALX', 'Al Iskandariyah', 'EG'),
	(843, 'EGASN', 'Aswan', 'EG'),
	(844, 'EGAST', 'Asyut', 'EG'),
	(845, 'EGBA', 'Al Bahr al Ahmar', 'EG'),
	(846, 'EGBH', 'Al Buhayrah', 'EG'),
	(847, 'EGBNS', 'Bani Suwayf', 'EG'),
	(848, 'EGC', 'Al Qahirah', 'EG'),
	(849, 'EGDK', 'Ad Daqahliyah', 'EG'),
	(850, 'EGDT', 'Dumyat', 'EG'),
	(851, 'EGFYM', 'Al Fayyum', 'EG'),
	(852, 'EGGH', 'Al Gharbiyah', 'EG'),
	(853, 'EGGZ', 'Al Jizah', 'EG'),
	(854, 'EGIS', 'Al Ismailiyah', 'EG'),
	(855, 'EGJS', 'Janub Sina', 'EG'),
	(856, 'EGKB', 'Al Qalyubiyah', 'EG'),
	(857, 'EGKFS', 'Kafr ash Shaykh', 'EG'),
	(858, 'EGKN', 'Qina', 'EG'),
	(859, 'EGLX', 'Al Uqsur', 'EG'),
	(860, 'EGMN', 'Al Minya', 'EG'),
	(861, 'EGMNF', 'Al Minufiyah', 'EG'),
	(862, 'EGMT', 'Matruh', 'EG'),
	(863, 'EGPTS', 'Bur Said', 'EG'),
	(864, 'EGSHG', 'Suhaj', 'EG'),
	(865, 'EGSHR', 'Ash Sharqiyah', 'EG'),
	(866, 'EGSIN', 'Shamal Sina', 'EG'),
	(867, 'EGSUZ', 'As Suways', 'EG'),
	(868, 'EGWAD', 'Al Wadi al Jadid', 'EG'),
	(869, NULL, 'Oued Ed-Dahab-Lagouira', 'EH'),
	(870, NULL, 'Western Sahara', 'EH'),
	(871, 'ERAN', 'Ansaba', 'ER'),
	(872, 'ERDK', 'Janubi al Bahri al Ahmar', 'ER'),
	(873, 'ERDU', 'Al Janubi', 'ER'),
	(874, 'ERGB', 'Qash-Barkah', 'ER'),
	(875, 'ERMA', 'Al Awsat', 'ER'),
	(876, 'ERSK', 'Shimali al Bahri al Ahmar', 'ER'),
	(877, 'ESAN', 'Andalucia', 'ES'),
	(878, 'ESAR', 'Aragon', 'ES'),
	(879, 'ESAS', 'Asturias, Principado de', 'ES'),
	(880, 'ESCB', 'Cantabria', 'ES'),
	(881, 'ESCE', 'Ceuta', 'ES'),
	(882, 'ESCL', 'Castilla y Leon', 'ES'),
	(883, 'ESCM', 'Castilla-La Mancha', 'ES'),
	(884, 'ESCN', 'Canarias', 'ES'),
	(885, 'ESCT', 'Catalunya', 'ES'),
	(886, 'ESEX', 'Extremadura', 'ES'),
	(887, 'ESGA', 'Galicia', 'ES'),
	(888, 'ESIB', 'Illes Balears', 'ES'),
	(889, 'ESMC', 'Murcia, Region de', 'ES'),
	(890, 'ESMD', 'Madrid, Comunidad de', 'ES'),
	(891, 'ESML', 'Melilla', 'ES'),
	(892, 'ESNC', 'Navarra, Comunidad Foral de', 'ES'),
	(893, 'ESPV', 'Pais Vasco', 'ES'),
	(894, 'ESRI', 'La Rioja', 'ES'),
	(895, 'ESVC', 'Valenciana, Comunidad', 'ES'),
	(896, 'ETAA', 'Adis Abeba', 'ET'),
	(897, 'ETAF', 'Afar', 'ET'),
	(898, 'ETAM', 'Amara', 'ET'),
	(899, 'ETBE', 'Binshangul Gumuz', 'ET'),
	(900, 'ETDD', 'Dire Dawa', 'ET'),
	(901, 'ETGA', 'Gambela Hizboch', 'ET'),
	(902, 'ETHA', 'Hareri Hizb', 'ET'),
	(903, 'ETOR', 'Oromiya', 'ET'),
	(904, 'ETSN', 'YeDebub Biheroch Bihereseboch na Hizboch', 'ET'),
	(905, 'ETSO', 'Sumale', 'ET'),
	(906, 'ETTI', 'Tigray', 'ET'),
	(907, 'FI02', 'Etela-Karjala', 'FI'),
	(908, 'FI03', 'Etela-Pohjanmaa', 'FI'),
	(909, 'FI04', 'Etela-Savo', 'FI'),
	(910, 'FI05', 'Kainuu', 'FI'),
	(911, 'FI06', 'Kanta-Hame', 'FI'),
	(912, 'FI07', 'Keski-Pohjanmaa', 'FI'),
	(913, 'FI08', 'Keski-Suomi', 'FI'),
	(914, 'FI09', 'Kymenlaakso', 'FI'),
	(915, 'FI10', 'Lappi', 'FI'),
	(916, 'FI11', 'Pirkanmaa', 'FI'),
	(917, 'FI12', 'Pohjanmaa', 'FI'),
	(918, 'FI13', 'Pohjois-Karjala', 'FI'),
	(919, 'FI14', 'Pohjois-Pohjanmaa', 'FI'),
	(920, 'FI15', 'Pohjois-Savo', 'FI'),
	(921, 'FI16', 'Paijat-Hame', 'FI'),
	(922, 'FI17', 'Satakunta', 'FI'),
	(923, 'FI18', 'Uusimaa', 'FI'),
	(924, 'FI19', 'Varsinais-Suomi', 'FI'),
	(925, 'FJC', 'Central', 'FJ'),
	(926, 'FJN', 'Northern', 'FJ'),
	(927, 'FJW', 'Western', 'FJ'),
	(928, NULL, 'Falkland Islands', 'FK'),
	(929, 'FMKSA', 'Kosrae', 'FM'),
	(930, 'FMPNI', 'Pohnpei', 'FM'),
	(931, 'FMTRK', 'Chuuk', 'FM'),
	(932, 'FMYAP', 'Yap', 'FM'),
	(933, NULL, 'Eysturoy', 'FO'),
	(934, NULL, 'Nordoyar', 'FO'),
	(935, NULL, 'Sandoy', 'FO'),
	(936, NULL, 'Streymoy', 'FO'),
	(937, NULL, 'Suduroy', 'FO'),
	(938, NULL, 'Vagar', 'FO'),
	(939, 'FRARA', 'Auvergne-Rhone-Alpes', 'FR'),
	(940, 'FRBFC', 'Bourgogne-Franche-Comte', 'FR'),
	(941, 'FRCVL', 'Centre-Val de Loire', 'FR'),
	(942, 'FRE', 'Bretagne', 'FR'),
	(943, 'FRGES', 'Grand-Est', 'FR'),
	(944, 'FRH', 'Corse', 'FR'),
	(945, 'FRHDF', 'Hauts-de-France', 'FR'),
	(946, 'FRJ', 'Ile-de-France', 'FR'),
	(947, 'FRNAQ', 'Nouvelle-Aquitaine', 'FR'),
	(948, 'FRNOR', 'Normandie', 'FR'),
	(949, 'FROCC', 'Occitanie', 'FR'),
	(950, 'FRPAC', 'Provence-Alpes-Cote dAzur', 'FR'),
	(951, 'FRR', 'Pays-de-la-Loire', 'FR'),
	(952, 'GA1', 'Estuaire', 'GA'),
	(953, 'GA2', 'Haut-Ogooue', 'GA'),
	(954, 'GA3', 'Moyen-Ogooue', 'GA'),
	(955, 'GA4', 'Ngounie', 'GA'),
	(956, 'GA5', 'Nyanga', 'GA'),
	(957, 'GA6', 'Ogooue-Ivindo', 'GA'),
	(958, 'GA7', 'Ogooue-Lolo', 'GA'),
	(959, 'GA8', 'Ogooue-Maritime', 'GA'),
	(960, 'GA9', 'Woleu-Ntem', 'GA'),
	(961, 'GBENG', 'England', 'GB'),
	(962, 'GBNIR', 'Northern Ireland', 'GB'),
	(963, 'GBSCT', 'Scotland', 'GB'),
	(964, 'GBWLS', 'Wales', 'GB'),
	(965, 'GD01', 'Saint Andrew', 'GD'),
	(966, 'GD02', 'Saint David', 'GD'),
	(967, 'GD03', 'Saint George', 'GD'),
	(968, 'GD04', 'Saint John', 'GD'),
	(969, 'GD05', 'Saint Mark', 'GD'),
	(970, 'GD06', 'Saint Patrick', 'GD'),
	(971, 'GEAB', 'Abkhazia', 'GE'),
	(972, 'GEAJ', 'Ajaria', 'GE'),
	(973, 'GEGU', 'Guria', 'GE'),
	(974, 'GEIM', 'Imereti', 'GE'),
	(975, 'GEKA', 'Kakheti', 'GE'),
	(976, 'GEKK', 'Kvemo Kartli', 'GE'),
	(977, 'GEMM', 'Mtskheta-Mtianeti', 'GE'),
	(978, 'GERL', 'Racha-Lechkhumi-Kvemo Svaneti', 'GE'),
	(979, 'GESJ', 'Samtskhe-Javakheti', 'GE'),
	(980, 'GESK', 'Shida Kartli', 'GE'),
	(981, 'GESZ', 'Samegrelo-Zemo Svaneti', 'GE'),
	(982, 'GETB', 'Tbilisi', 'GE'),
	(983, NULL, 'Guyane', 'GF'),
	(984, NULL, 'Guernsey (general)', 'GG'),
	(985, 'GHAA', 'Greater Accra', 'GH'),
	(986, 'GHAH', 'Ashanti', 'GH'),
	(987, 'GHBA', 'Brong-Ahafo', 'GH'),
	(988, 'GHCP', 'Central', 'GH'),
	(989, 'GHEP', 'Eastern', 'GH'),
	(990, 'GHNP', 'Northern', 'GH'),
	(991, 'GHTV', 'Volta', 'GH'),
	(992, 'GHUE', 'Upper East', 'GH'),
	(993, 'GHUW', 'Upper West', 'GH'),
	(994, 'GHWP', 'Western', 'GH'),
	(995, NULL, 'Gibraltar', 'GI'),
	(996, 'GLKU', 'Kommune Kujalleq', 'GL'),
	(997, 'GLQA', 'Qaasuitsup Kommunia', 'GL'),
	(998, 'GLQE', 'Qeqqata Kommunia', 'GL'),
	(999, 'GLSM', 'Kommuneqarfik Sermersooq', 'GL'),
	(1000, 'GMB', 'Banjul', 'GM');
INSERT INTO public.sehir VALUES
	(1001, 'GML', 'Lower River', 'GM'),
	(1002, 'GMM', 'Central River', 'GM'),
	(1003, 'GMN', 'North Bank', 'GM'),
	(1004, 'GMU', 'Upper River', 'GM'),
	(1005, 'GMW', 'Western', 'GM'),
	(1006, 'GNB', 'Boke', 'GN'),
	(1007, 'GNBE', 'Beyla', 'GN'),
	(1008, 'GNBF', 'Boffa', 'GN'),
	(1009, 'GNC', 'Conakry', 'GN'),
	(1010, 'GNCO', 'Coyah', 'GN'),
	(1011, 'GND', 'Kindia', 'GN'),
	(1012, 'GNDB', 'Dabola', 'GN'),
	(1013, 'GNDI', 'Dinguiraye', 'GN'),
	(1014, 'GNDL', 'Dalaba', 'GN'),
	(1015, 'GNDU', 'Dubreka', 'GN'),
	(1016, 'GNF', 'Faranah', 'GN'),
	(1017, 'GNFO', 'Forecariah', 'GN'),
	(1018, 'GNFR', 'Fria', 'GN'),
	(1019, 'GNGA', 'Gaoual', 'GN'),
	(1020, 'GNGU', 'Guekedou', 'GN'),
	(1021, 'GNK', 'Kankan', 'GN'),
	(1022, 'GNKB', 'Koubia', 'GN'),
	(1023, 'GNKE', 'Kerouane', 'GN'),
	(1024, 'GNKN', 'Koundara', 'GN'),
	(1025, 'GNKO', 'Kouroussa', 'GN'),
	(1026, 'GNKS', 'Kissidougou', 'GN'),
	(1027, 'GNL', 'Labe', 'GN'),
	(1028, 'GNLE', 'Lelouma', 'GN'),
	(1029, 'GNLO', 'Lola', 'GN'),
	(1030, 'GNM', 'Mamou', 'GN'),
	(1031, 'GNMC', 'Macenta', 'GN'),
	(1032, 'GNMD', 'Mandiana', 'GN'),
	(1033, 'GNML', 'Mali', 'GN'),
	(1034, 'GNN', 'Nzerekore', 'GN'),
	(1035, 'GNPI', 'Pita', 'GN'),
	(1036, 'GNSI', 'Siguiri', 'GN'),
	(1037, 'GNTE', 'Telimele', 'GN'),
	(1038, 'GNTO', 'Tougue', 'GN'),
	(1039, 'GNYO', 'Yomou', 'GN'),
	(1040, NULL, 'Guadeloupe', 'GP'),
	(1041, 'GQAN', 'Annobon', 'GQ'),
	(1042, 'GQBN', 'Bioko Norte', 'GQ'),
	(1043, 'GQBS', 'Bioko Sur', 'GQ'),
	(1044, 'GQCS', 'Centro Sur', 'GQ'),
	(1045, 'GQKN', 'Kie-Ntem', 'GQ'),
	(1046, 'GQLI', 'Litoral', 'GQ'),
	(1047, 'GQWN', 'Wele-Nzas', 'GQ'),
	(1048, 'GRA', 'Anatoliki Makedonia kai Thraki', 'GR'),
	(1049, 'GRB', 'Kentriki Makedonia', 'GR'),
	(1050, 'GRC', 'Dytiki Makedonia', 'GR'),
	(1051, 'GRD', 'Ipeiros', 'GR'),
	(1052, 'GRE', 'Thessalia', 'GR'),
	(1053, 'GRF', 'Ionia Nisia', 'GR'),
	(1054, 'GRG', 'Dytiki Ellada', 'GR'),
	(1055, 'GRH', 'Sterea Ellada', 'GR'),
	(1056, 'GRI', 'Attiki', 'GR'),
	(1057, 'GRJ', 'Peloponnisos', 'GR'),
	(1058, 'GRK', 'Voreio Aigaio', 'GR'),
	(1059, 'GRL', 'Notio Aigaio', 'GR'),
	(1060, 'GRM', 'Kriti', 'GR'),
	(1061, NULL, 'South Georgia and the South Sandwich Islands', 'GS'),
	(1062, 'GTAV', 'Alta Verapaz', 'GT'),
	(1063, 'GTBV', 'Baja Verapaz', 'GT'),
	(1064, 'GTCM', 'Chimaltenango', 'GT'),
	(1065, 'GTCQ', 'Chiquimula', 'GT'),
	(1066, 'GTES', 'Escuintla', 'GT'),
	(1067, 'GTGU', 'Guatemala', 'GT'),
	(1068, 'GTHU', 'Huehuetenango', 'GT'),
	(1069, 'GTIZ', 'Izabal', 'GT'),
	(1070, 'GTJA', 'Jalapa', 'GT'),
	(1071, 'GTJU', 'Jutiapa', 'GT'),
	(1072, 'GTPE', 'Peten', 'GT'),
	(1073, 'GTPR', 'El Progreso', 'GT'),
	(1074, 'GTQC', 'Quiche', 'GT'),
	(1075, 'GTQZ', 'Quetzaltenango', 'GT'),
	(1076, 'GTRE', 'Retalhuleu', 'GT'),
	(1077, 'GTSA', 'Sacatepequez', 'GT'),
	(1078, 'GTSM', 'San Marcos', 'GT'),
	(1079, 'GTSO', 'Solola', 'GT'),
	(1080, 'GTSR', 'Santa Rosa', 'GT'),
	(1081, 'GTSU', 'Suchitepequez', 'GT'),
	(1082, 'GTTO', 'Totonicapan', 'GT'),
	(1083, 'GTZA', 'Zacapa', 'GT'),
	(1084, NULL, 'Agana Heights Municipality', 'GU'),
	(1085, NULL, 'Agat Municipality', 'GU'),
	(1086, NULL, 'Asan-Maina Municipality', 'GU'),
	(1087, NULL, 'Barrigada Municipality', 'GU'),
	(1088, NULL, 'Chalan Pago-Ordot Municipality', 'GU'),
	(1089, NULL, 'Dededo Municipality', 'GU'),
	(1090, NULL, 'Hagatna Municipality', 'GU'),
	(1091, NULL, 'Inarajan Municipality', 'GU'),
	(1092, NULL, 'Mangilao Municipality', 'GU'),
	(1093, NULL, 'Merizo Municipality', 'GU'),
	(1094, NULL, 'Mongmong-Toto-Maite Municipality', 'GU'),
	(1095, NULL, 'Piti Municipality', 'GU'),
	(1096, NULL, 'Santa Rita Municipality', 'GU'),
	(1097, NULL, 'Sinajana Municipality', 'GU'),
	(1098, NULL, 'Talofofo Municipality', 'GU'),
	(1099, NULL, 'Tamuning-Tumon-Harmon Municipality', 'GU'),
	(1100, NULL, 'Umatac Municipality', 'GU'),
	(1101, NULL, 'Yigo Municipality', 'GU'),
	(1102, NULL, 'Yona Municipality', 'GU'),
	(1103, 'GWBA', 'Bafata', 'GW'),
	(1104, 'GWBL', 'Bolama', 'GW'),
	(1105, 'GWBM', 'Biombo', 'GW'),
	(1106, 'GWBS', 'Bissau', 'GW'),
	(1107, 'GWCA', 'Cacheu', 'GW'),
	(1108, 'GWGA', 'Gabu', 'GW'),
	(1109, 'GWOI', 'Oio', 'GW'),
	(1110, 'GWQU', 'Quinara', 'GW'),
	(1111, 'GWTO', 'Tombali', 'GW'),
	(1112, 'GYCU', 'Cuyuni-Mazaruni', 'GY'),
	(1113, 'GYDE', 'Demerara-Mahaica', 'GY'),
	(1114, 'GYEB', 'East Berbice-Corentyne', 'GY'),
	(1115, 'GYES', 'Essequibo Islands-West Demerara', 'GY'),
	(1116, 'GYMA', 'Mahaica-Berbice', 'GY'),
	(1117, 'GYPM', 'Pomeroon-Supenaam', 'GY'),
	(1118, 'GYUD', 'Upper Demerara-Berbice', 'GY'),
	(1119, NULL, 'Hong Kong (SAR)', 'HK'),
	(1120, 'HNAT', 'Atlantida', 'HN'),
	(1121, 'HNCH', 'Choluteca', 'HN'),
	(1122, 'HNCL', 'Colon', 'HN'),
	(1123, 'HNCM', 'Comayagua', 'HN'),
	(1124, 'HNCP', 'Copan', 'HN'),
	(1125, 'HNCR', 'Cortes', 'HN'),
	(1126, 'HNEP', 'El Paraiso', 'HN'),
	(1127, 'HNFM', 'Francisco Morazan', 'HN'),
	(1128, 'HNGD', 'Gracias a Dios', 'HN'),
	(1129, 'HNIB', 'Islas de la Bahia', 'HN'),
	(1130, 'HNIN', 'Intibuca', 'HN'),
	(1131, 'HNLE', 'Lempira', 'HN'),
	(1132, 'HNLP', 'La Paz', 'HN'),
	(1133, 'HNOC', 'Ocotepeque', 'HN'),
	(1134, 'HNOL', 'Olancho', 'HN'),
	(1135, 'HNSB', 'Santa Barbara', 'HN'),
	(1136, 'HNVA', 'Valle', 'HN'),
	(1137, 'HNYO', 'Yoro', 'HN'),
	(1138, 'HR01', 'Zagrebacka zupanija', 'HR'),
	(1139, 'HR02', 'Krapinsko-zagorska zupanija', 'HR'),
	(1140, 'HR03', 'Sisacko-moslavacka zupanija', 'HR'),
	(1141, 'HR04', 'Karlovacka zupanija', 'HR'),
	(1142, 'HR05', 'Varazdinska zupanija', 'HR'),
	(1143, 'HR06', 'Koprivnicko-krizevacka zupanija', 'HR'),
	(1144, 'HR07', 'Bjelovarsko-bilogorska zupanija', 'HR'),
	(1145, 'HR08', 'Primorsko-goranska zupanija', 'HR'),
	(1146, 'HR09', 'Licko-senjska zupanija', 'HR'),
	(1147, 'HR10', 'Viroviticko-podravska zupanija', 'HR'),
	(1148, 'HR11', 'Pozesko-slavonska zupanija', 'HR'),
	(1149, 'HR12', 'Brodsko-posavska zupanija', 'HR'),
	(1150, 'HR13', 'Zadarska zupanija', 'HR'),
	(1151, 'HR14', 'Osjecko-baranjska zupanija', 'HR'),
	(1152, 'HR15', 'Sibensko-kninska zupanija', 'HR'),
	(1153, 'HR16', 'Vukovarsko-srijemska zupanija', 'HR'),
	(1154, 'HR17', 'Splitsko-dalmatinska zupanija', 'HR'),
	(1155, 'HR18', 'Istarska zupanija', 'HR'),
	(1156, 'HR19', 'Dubrovacko-neretvanska zupanija', 'HR'),
	(1157, 'HR20', 'Medimurska zupanija', 'HR'),
	(1158, 'HR21', 'Grad Zagreb', 'HR'),
	(1159, 'HTAR', 'Artibonite', 'HT'),
	(1160, 'HTCE', 'Centre', 'HT'),
	(1161, 'HTGA', 'GrandeAnse', 'HT'),
	(1162, 'HTND', 'Nord', 'HT'),
	(1163, 'HTNE', 'Nord-Est', 'HT'),
	(1164, 'HTNI', 'Nippes', 'HT'),
	(1165, 'HTNO', 'Nord-Ouest', 'HT'),
	(1166, 'HTOU', 'Ouest', 'HT'),
	(1167, 'HTSD', 'Sud', 'HT'),
	(1168, 'HTSE', 'Sud-Est', 'HT'),
	(1169, 'HUBA', 'Baranya', 'HU'),
	(1170, 'HUBE', 'Bekes', 'HU'),
	(1171, 'HUBK', 'Bacs-Kiskun', 'HU'),
	(1172, 'HUBU', 'Budapest', 'HU'),
	(1173, 'HUBZ', 'Borsod-Abauj-Zemplen', 'HU'),
	(1174, 'HUCS', 'Csongrad', 'HU'),
	(1175, 'HUFE', 'Fejer', 'HU'),
	(1176, 'HUGS', 'Gyor-Moson-Sopron', 'HU'),
	(1177, 'HUHB', 'Hajdu-Bihar', 'HU'),
	(1178, 'HUHE', 'Heves', 'HU'),
	(1179, 'HUJN', 'Jasz-Nagykun-Szolnok', 'HU'),
	(1180, 'HUKE', 'Komarom-Esztergom', 'HU'),
	(1181, 'HUNO', 'Nograd', 'HU'),
	(1182, 'HUPE', 'Pest', 'HU'),
	(1183, 'HUSO', 'Somogy', 'HU'),
	(1184, 'HUSZ', 'Szabolcs-Szatmar-Bereg', 'HU'),
	(1185, 'HUTO', 'Tolna', 'HU'),
	(1186, 'HUVA', 'Vas', 'HU'),
	(1187, 'HUVM', 'Veszprem', 'HU'),
	(1188, 'HUZA', 'Zala', 'HU'),
	(1189, 'IDAC', 'Aceh', 'ID'),
	(1190, 'IDBA', 'Bali', 'ID'),
	(1191, 'IDBB', 'Kepulauan Bangka Belitung', 'ID'),
	(1192, 'IDBE', 'Bengkulu', 'ID'),
	(1193, 'IDBT', 'Banten', 'ID'),
	(1194, 'IDGO', 'Gorontalo', 'ID'),
	(1195, 'IDJA', 'Jambi', 'ID'),
	(1196, 'IDJB', 'Jawa Barat', 'ID'),
	(1197, 'IDJI', 'Jawa Timur', 'ID'),
	(1198, 'IDJK', 'Jakarta Raya', 'ID'),
	(1199, 'IDJT', 'Jawa Tengah', 'ID'),
	(1200, 'IDKB', 'Kalimantan Barat', 'ID'),
	(1201, 'IDKI', 'Kalimantan Timur', 'ID'),
	(1202, 'IDKR', 'Kepulauan Riau', 'ID'),
	(1203, 'IDKS', 'Kalimantan Selatan', 'ID'),
	(1204, 'IDKT', 'Kalimantan Tengah', 'ID'),
	(1205, 'IDLA', 'Lampung', 'ID'),
	(1206, 'IDML', 'Maluku', 'ID'),
	(1207, 'IDMU', 'Maluku Utara', 'ID'),
	(1208, 'IDNB', 'Nusa Tenggara Barat', 'ID'),
	(1209, 'IDNT', 'Nusa Tenggara Timur', 'ID'),
	(1210, 'IDPB', 'Papua Barat', 'ID'),
	(1211, 'IDPP', 'Papua', 'ID'),
	(1212, 'IDRI', 'Riau', 'ID'),
	(1213, 'IDSA', 'Sulawesi Utara', 'ID'),
	(1214, 'IDSB', 'Sumatera Barat', 'ID'),
	(1215, 'IDSG', 'Sulawesi Tenggara', 'ID'),
	(1216, 'IDSN', 'Sulawesi Selatan', 'ID'),
	(1217, 'IDSR', 'Sulawesi Barat', 'ID'),
	(1218, 'IDSS', 'Sumatera Selatan', 'ID'),
	(1219, 'IDST', 'Sulawesi Tengah', 'ID'),
	(1220, 'IDSU', 'Sumatera Utara', 'ID'),
	(1221, 'IDYO', 'Yogyakarta', 'ID'),
	(1222, 'IECE', 'Clare', 'IE'),
	(1223, 'IECN', 'Cavan', 'IE'),
	(1224, 'IECO', 'Cork', 'IE'),
	(1225, 'IECW', 'Carlow', 'IE'),
	(1226, 'IED', 'Dublin', 'IE'),
	(1227, 'IEDL', 'Donegal', 'IE'),
	(1228, 'IEG', 'Galway', 'IE'),
	(1229, 'IEKE', 'Kildare', 'IE'),
	(1230, 'IEKK', 'Kilkenny', 'IE'),
	(1231, 'IEKY', 'Kerry', 'IE'),
	(1232, 'IELD', 'Longford', 'IE'),
	(1233, 'IELH', 'Louth', 'IE'),
	(1234, 'IELK', 'Limerick', 'IE'),
	(1235, 'IELM', 'Leitrim', 'IE'),
	(1236, 'IELS', 'Laois', 'IE'),
	(1237, 'IEMH', 'Meath', 'IE'),
	(1238, 'IEMN', 'Monaghan', 'IE'),
	(1239, 'IEMO', 'Mayo', 'IE'),
	(1240, 'IEOY', 'Offaly', 'IE'),
	(1241, 'IERN', 'Roscommon', 'IE'),
	(1242, 'IESO', 'Sligo', 'IE'),
	(1243, 'IETA', 'Tipperary', 'IE'),
	(1244, 'IEWD', 'Waterford', 'IE'),
	(1245, 'IEWH', 'Westmeath', 'IE'),
	(1246, 'IEWW', 'Wicklow', 'IE'),
	(1247, 'IEWX', 'Wexford', 'IE'),
	(1248, 'ILD', 'HaDarom', 'IL'),
	(1249, 'ILHA', 'Hefa', 'IL'),
	(1250, 'ILJM', 'Yerushalayim', 'IL');
INSERT INTO public.sehir VALUES
	(1251, 'ILM', 'HaMerkaz', 'IL'),
	(1252, 'ILTA', 'Tel Aviv', 'IL'),
	(1253, 'ILZ', 'HaTsafon', 'IL'),
	(1254, NULL, 'Isle of Man', 'IM'),
	(1255, 'INAN', 'Andaman and Nicobar Islands', 'IN'),
	(1256, 'INAP', 'Andhra Pradesh', 'IN'),
	(1257, 'INAR', 'Arunachal Pradesh', 'IN'),
	(1258, 'INAS', 'Assam', 'IN'),
	(1259, 'INBR', 'Bihar', 'IN'),
	(1260, 'INCH', 'Chandigarh', 'IN'),
	(1261, 'INCT', 'Chhattisgarh', 'IN'),
	(1262, 'INDD', 'Daman and Diu', 'IN'),
	(1263, 'INDL', 'Delhi', 'IN'),
	(1264, 'INDN', 'Dadra and Nagar Haveli', 'IN'),
	(1265, 'INGA', 'Goa', 'IN'),
	(1266, 'INGJ', 'Gujarat', 'IN'),
	(1267, 'INHP', 'Himachal Pradesh', 'IN'),
	(1268, 'INHR', 'Haryana', 'IN'),
	(1269, 'INJH', 'Jharkhand', 'IN'),
	(1270, 'INJK', 'Jammu and Kashmir', 'IN'),
	(1271, 'INKA', 'Karnataka', 'IN'),
	(1272, 'INKL', 'Kerala', 'IN'),
	(1273, 'INLD', 'Lakshadweep', 'IN'),
	(1274, 'INMH', 'Maharashtra', 'IN'),
	(1275, 'INML', 'Meghalaya', 'IN'),
	(1276, 'INMN', 'Manipur', 'IN'),
	(1277, 'INMP', 'Madhya Pradesh', 'IN'),
	(1278, 'INMZ', 'Mizoram', 'IN'),
	(1279, 'INNL', 'Nagaland', 'IN'),
	(1280, 'INOR', 'Odisha', 'IN'),
	(1281, 'INPB', 'Punjab', 'IN'),
	(1282, 'INPY', 'Puducherry', 'IN'),
	(1283, 'INRJ', 'Rajasthan', 'IN'),
	(1284, 'INSK', 'Sikkim', 'IN'),
	(1285, 'INTG', 'Telangana', 'IN'),
	(1286, 'INTN', 'Tamil Nadu', 'IN'),
	(1287, 'INTR', 'Tripura', 'IN'),
	(1288, 'INUP', 'Uttar Pradesh', 'IN'),
	(1289, 'INUT', 'Uttarakhand', 'IN'),
	(1290, 'INWB', 'West Bengal', 'IN'),
	(1291, NULL, 'British Indian Ocean Territory', 'IO'),
	(1292, 'IQAN', 'Al Anbar', 'IQ'),
	(1293, 'IQAR', 'Arbil', 'IQ'),
	(1294, 'IQBA', 'Al Basrah', 'IQ'),
	(1295, 'IQBB', 'Babil', 'IQ'),
	(1296, 'IQBG', 'Baghdad', 'IQ'),
	(1297, 'IQDA', 'Dahuk', 'IQ'),
	(1298, 'IQDI', 'Diyala', 'IQ'),
	(1299, 'IQDQ', 'Dhi Qar', 'IQ'),
	(1300, 'IQKA', 'Karbala', 'IQ'),
	(1301, 'IQKI', 'Kirkuk', 'IQ'),
	(1302, 'IQMA', 'Maysan', 'IQ'),
	(1303, 'IQMU', 'Al Muthanna', 'IQ'),
	(1304, 'IQNA', 'An Najaf', 'IQ'),
	(1305, 'IQNI', 'Ninawa', 'IQ'),
	(1306, 'IQQA', 'Al Qadisiyah', 'IQ'),
	(1307, 'IQSD', 'Salah ad Din', 'IQ'),
	(1308, 'IQSU', 'As Sulaymaniyah', 'IQ'),
	(1309, 'IQWA', 'Wasit', 'IQ'),
	(1310, 'IR01', 'Azarbayjan-e Sharqi', 'IR'),
	(1311, 'IR02', 'Azarbayjan-e Gharbi', 'IR'),
	(1312, 'IR03', 'Ardabil', 'IR'),
	(1313, 'IR04', 'Esfahan', 'IR'),
	(1314, 'IR05', 'Ilam', 'IR'),
	(1315, 'IR06', 'Bushehr', 'IR'),
	(1316, 'IR07', 'Tehran', 'IR'),
	(1317, 'IR08', 'Chahar Mahal va Bakhtiari', 'IR'),
	(1318, 'IR10', 'Khuzestan', 'IR'),
	(1319, 'IR11', 'Zanjan', 'IR'),
	(1320, 'IR12', 'Semnan', 'IR'),
	(1321, 'IR13', 'Sistan va Baluchestan', 'IR'),
	(1322, 'IR14', 'Fars', 'IR'),
	(1323, 'IR15', 'Kerman', 'IR'),
	(1324, 'IR16', 'Kordestan', 'IR'),
	(1325, 'IR17', 'Kermanshah', 'IR'),
	(1326, 'IR18', 'Kohgiluyeh va Bowyer Ahmad', 'IR'),
	(1327, 'IR19', 'Gilan', 'IR'),
	(1328, 'IR20', 'Lorestan', 'IR'),
	(1329, 'IR21', 'Mazandaran', 'IR'),
	(1330, 'IR22', 'Markazi', 'IR'),
	(1331, 'IR23', 'Hormozgan', 'IR'),
	(1332, 'IR24', 'Hamadan', 'IR'),
	(1333, 'IR25', 'Yazd', 'IR'),
	(1334, 'IR26', 'Qom', 'IR'),
	(1335, 'IR27', 'Golestan', 'IR'),
	(1336, 'IR28', 'Qazvin', 'IR'),
	(1337, 'IR29', 'Khorasan-e Jonubi', 'IR'),
	(1338, 'IR30', 'Khorasan-e Razavi', 'IR'),
	(1339, 'IR31', 'Khorasan-e Shomali', 'IR'),
	(1340, 'IR32', 'Alborz', 'IR'),
	(1341, 'IS1', 'Hofudborgarsvaedi utan Reykjavikur', 'IS'),
	(1342, 'IS2', 'Sudurnes', 'IS'),
	(1343, 'IS3', 'Vesturland', 'IS'),
	(1344, 'IS4', 'Vestfirdir', 'IS'),
	(1345, 'IS5', 'Nordurland vestra', 'IS'),
	(1346, 'IS6', 'Nordurland eystra', 'IS'),
	(1347, 'IS7', 'Austurland', 'IS'),
	(1348, 'IS8', 'Sudurland', 'IS'),
	(1349, 'IT21', 'Piemonte', 'IT'),
	(1350, 'IT23', 'Valle dAosta', 'IT'),
	(1351, 'IT25', 'Lombardia', 'IT'),
	(1352, 'IT32', 'Trentino-Alto Adige', 'IT'),
	(1353, 'IT34', 'Veneto', 'IT'),
	(1354, 'IT36', 'Friuli-Venezia Giulia', 'IT'),
	(1355, 'IT42', 'Liguria', 'IT'),
	(1356, 'IT45', 'Emilia-Romagna', 'IT'),
	(1357, 'IT52', 'Toscana', 'IT'),
	(1358, 'IT55', 'Umbria', 'IT'),
	(1359, 'IT57', 'Marche', 'IT'),
	(1360, 'IT62', 'Lazio', 'IT'),
	(1361, 'IT65', 'Abruzzo', 'IT'),
	(1362, 'IT67', 'Molise', 'IT'),
	(1363, 'IT72', 'Campania', 'IT'),
	(1364, 'IT75', 'Puglia', 'IT'),
	(1365, 'IT77', 'Basilicata', 'IT'),
	(1366, 'IT78', 'Calabria', 'IT'),
	(1367, 'IT82', 'Sicilia', 'IT'),
	(1368, 'IT88', 'Sardegna', 'IT'),
	(1369, NULL, 'Jersey', 'JE'),
	(1370, 'JM01', 'Kingston', 'JM'),
	(1371, 'JM02', 'Saint Andrew', 'JM'),
	(1372, 'JM03', 'Saint Thomas', 'JM'),
	(1373, 'JM04', 'Portland', 'JM'),
	(1374, 'JM05', 'Saint Mary', 'JM'),
	(1375, 'JM06', 'Saint Ann', 'JM'),
	(1376, 'JM07', 'Trelawny', 'JM'),
	(1377, 'JM08', 'Saint James', 'JM'),
	(1378, 'JM09', 'Hanover', 'JM'),
	(1379, 'JM10', 'Westmoreland', 'JM'),
	(1380, 'JM11', 'Saint Elizabeth', 'JM'),
	(1381, 'JM12', 'Manchester', 'JM'),
	(1382, 'JM13', 'Clarendon', 'JM'),
	(1383, 'JM14', 'Saint Catherine', 'JM'),
	(1384, 'JOAM', 'Al Asimah', 'JO'),
	(1385, 'JOAQ', 'Al Aqabah', 'JO'),
	(1386, 'JOAT', 'At Tafilah', 'JO'),
	(1387, 'JOAZ', 'Az Zarqa', 'JO'),
	(1388, 'JOBA', 'Al Balqa', 'JO'),
	(1389, 'JOIR', 'Irbid', 'JO'),
	(1390, 'JOKA', 'Al Karak', 'JO'),
	(1391, 'JOMA', 'Al Mafraq', 'JO'),
	(1392, 'JOMD', 'Madaba', 'JO'),
	(1393, 'JOMN', 'Maan', 'JO'),
	(1394, 'JP01', 'Hokkaido', 'JP'),
	(1395, 'JP02', 'Aomori', 'JP'),
	(1396, 'JP03', 'Iwate', 'JP'),
	(1397, 'JP04', 'Miyagi', 'JP'),
	(1398, 'JP05', 'Akita', 'JP'),
	(1399, 'JP06', 'Yamagata', 'JP'),
	(1400, 'JP07', 'Fukushima', 'JP'),
	(1401, 'JP08', 'Ibaraki', 'JP'),
	(1402, 'JP09', 'Tochigi', 'JP'),
	(1403, 'JP10', 'Gunma', 'JP'),
	(1404, 'JP11', 'Saitama', 'JP'),
	(1405, 'JP12', 'Chiba', 'JP'),
	(1406, 'JP13', 'Tokyo', 'JP'),
	(1407, 'JP14', 'Kanagawa', 'JP'),
	(1408, 'JP15', 'Niigata', 'JP'),
	(1409, 'JP16', 'Toyama', 'JP'),
	(1410, 'JP17', 'Ishikawa', 'JP'),
	(1411, 'JP18', 'Fukui', 'JP'),
	(1412, 'JP19', 'Yamanashi', 'JP'),
	(1413, 'JP20', 'Nagano', 'JP'),
	(1414, 'JP21', 'Gifu', 'JP'),
	(1415, 'JP22', 'Shizuoka', 'JP'),
	(1416, 'JP23', 'Aichi', 'JP'),
	(1417, 'JP24', 'Mie', 'JP'),
	(1418, 'JP25', 'Shiga', 'JP'),
	(1419, 'JP26', 'Kyoto', 'JP'),
	(1420, 'JP27', 'Osaka', 'JP'),
	(1421, 'JP28', 'Hyogo', 'JP'),
	(1422, 'JP29', 'Nara', 'JP'),
	(1423, 'JP30', 'Wakayama', 'JP'),
	(1424, 'JP31', 'Tottori', 'JP'),
	(1425, 'JP32', 'Shimane', 'JP'),
	(1426, 'JP33', 'Okayama', 'JP'),
	(1427, 'JP34', 'Hiroshima', 'JP'),
	(1428, 'JP35', 'Yamaguchi', 'JP'),
	(1429, 'JP36', 'Tokushima', 'JP'),
	(1430, 'JP37', 'Kagawa', 'JP'),
	(1431, 'JP38', 'Ehime', 'JP'),
	(1432, 'JP39', 'Kochi', 'JP'),
	(1433, 'JP40', 'Fukuoka', 'JP'),
	(1434, 'JP41', 'Saga', 'JP'),
	(1435, 'JP42', 'Nagasaki', 'JP'),
	(1436, 'JP43', 'Kumamoto', 'JP'),
	(1437, 'JP44', 'Oita', 'JP'),
	(1438, 'JP45', 'Miyazaki', 'JP'),
	(1439, 'JP46', 'Kagoshima', 'JP'),
	(1440, 'JP47', 'Okinawa', 'JP'),
	(1441, 'KE01', 'Baringo', 'KE'),
	(1442, 'KE02', 'Bomet', 'KE'),
	(1443, 'KE03', 'Bungoma', 'KE'),
	(1444, 'KE04', 'Busia', 'KE'),
	(1445, 'KE06', 'Embu', 'KE'),
	(1446, 'KE07', 'Garissa', 'KE'),
	(1447, 'KE08', 'Homa Bay', 'KE'),
	(1448, 'KE09', 'Isiolo', 'KE'),
	(1449, 'KE10', 'Kajiado', 'KE'),
	(1450, 'KE11', 'Kakamega', 'KE'),
	(1451, 'KE12', 'Kericho', 'KE'),
	(1452, 'KE13', 'Kiambu', 'KE'),
	(1453, 'KE14', 'Kilifi', 'KE'),
	(1454, 'KE15', 'Kirinyaga', 'KE'),
	(1455, 'KE16', 'Kisii', 'KE'),
	(1456, 'KE17', 'Kisumu', 'KE'),
	(1457, 'KE18', 'Kitui', 'KE'),
	(1458, 'KE19', 'Kwale', 'KE'),
	(1459, 'KE20', 'Laikipia', 'KE'),
	(1460, 'KE21', 'Lamu', 'KE'),
	(1461, 'KE22', 'Machakos', 'KE'),
	(1462, 'KE23', 'Makueni', 'KE'),
	(1463, 'KE24', 'Mandera', 'KE'),
	(1464, 'KE25', 'Marsabit', 'KE'),
	(1465, 'KE26', 'Meru', 'KE'),
	(1466, 'KE27', 'Migori', 'KE'),
	(1467, 'KE28', 'Mombasa', 'KE'),
	(1468, 'KE29', 'Muranga', 'KE'),
	(1469, 'KE30', 'Nairobi City', 'KE'),
	(1470, 'KE31', 'Nakuru', 'KE'),
	(1471, 'KE32', 'Nandi', 'KE'),
	(1472, 'KE33', 'Narok', 'KE'),
	(1473, 'KE34', 'Nyamira', 'KE'),
	(1474, 'KE36', 'Nyeri', 'KE'),
	(1475, 'KE37', 'Samburu', 'KE'),
	(1476, 'KE38', 'Siaya', 'KE'),
	(1477, 'KE39', 'Taita/Taveta', 'KE'),
	(1478, 'KE40', 'Tana River', 'KE'),
	(1479, 'KE41', 'Tharaka-Nithi', 'KE'),
	(1480, 'KE42', 'Trans Nzoia', 'KE'),
	(1481, 'KE43', 'Turkana', 'KE'),
	(1482, 'KE44', 'Uasin Gishu', 'KE'),
	(1483, 'KE45', 'Vihiga', 'KE'),
	(1484, 'KE46', 'Wajir', 'KE'),
	(1485, 'KE47', 'West Pokot', 'KE'),
	(1486, 'KGB', 'Batken', 'KG'),
	(1487, 'KGC', 'Chuy', 'KG'),
	(1488, 'KGGB', 'Bishkek', 'KG'),
	(1489, 'KGGO', 'Osh', 'KG'),
	(1490, 'KGJ', 'Jalal-Abad', 'KG'),
	(1491, 'KGN', 'Naryn', 'KG'),
	(1492, 'KGT', 'Talas', 'KG'),
	(1493, 'KGY', 'Ysyk-Kol', 'KG'),
	(1494, 'KH1', 'Banteay Mean Chey', 'KH'),
	(1495, 'KH10', 'Kracheh', 'KH'),
	(1496, 'KH11', 'Mondol Kiri', 'KH'),
	(1497, 'KH12', 'Phnom Penh', 'KH'),
	(1498, 'KH13', 'Preah Vihear', 'KH'),
	(1499, 'KH14', 'Prey Veaeng', 'KH'),
	(1500, 'KH15', 'Pousaat', 'KH');
INSERT INTO public.sehir VALUES
	(1501, 'KH16', 'Rotanak Kiri', 'KH'),
	(1502, 'KH17', 'Siem Reab', 'KH'),
	(1503, 'KH18', 'Krong Preah Sihanouk', 'KH'),
	(1504, 'KH19', 'Stueng Traeng', 'KH'),
	(1505, 'KH2', 'Baat Dambang', 'KH'),
	(1506, 'KH20', 'Svaay Rieng', 'KH'),
	(1507, 'KH21', 'Taakaev', 'KH'),
	(1508, 'KH22', 'Otdar Mean Chey', 'KH'),
	(1509, 'KH23', 'Krong Kaeb', 'KH'),
	(1510, 'KH24', 'Krong Pailin', 'KH'),
	(1511, 'KH3', 'Kampong Chaam', 'KH'),
	(1512, 'KH4', 'Kampong Chhnang', 'KH'),
	(1513, 'KH5', 'Kampong Spueu', 'KH'),
	(1514, 'KH6', 'Kampong Thum', 'KH'),
	(1515, 'KH7', 'Kampot', 'KH'),
	(1516, 'KH8', 'Kandaal', 'KH'),
	(1517, 'KH9', 'Kaoh Kong', 'KH'),
	(1518, 'KIG', 'Gilbert Islands', 'KI'),
	(1519, 'KIL', 'Line Islands', 'KI'),
	(1520, 'KK01', 'Lefkosa', 'KK'),
	(1521, 'KK02', 'Gazimagusa', 'KK'),
	(1522, 'KK03', 'Girne', 'KK'),
	(1523, 'KK04', 'Güzelyurt', 'KK'),
	(1524, 'KMA', 'Anjouan', 'KM'),
	(1525, 'KMG', 'Grande Comore', 'KM'),
	(1526, 'KMM', 'Moheli', 'KM'),
	(1527, 'KN03', 'Saint George Basseterre', 'KN'),
	(1528, 'KN10', 'Saint Paul Charlestown', 'KN'),
	(1529, 'KP01', 'Pyongyang', 'KP'),
	(1530, 'KP02', 'Pyongan-namdo', 'KP'),
	(1531, 'KP03', 'Pyongan-bukto', 'KP'),
	(1532, 'KP04', 'Chagang-do', 'KP'),
	(1533, 'KP05', 'Hwanghae-namdo', 'KP'),
	(1534, 'KP06', 'Hwanghae-bukto', 'KP'),
	(1535, 'KP07', 'Kangwon-do', 'KP'),
	(1536, 'KP08', 'Hamgyong-namdo', 'KP'),
	(1537, 'KP09', 'Hamgyong-bukto', 'KP'),
	(1538, 'KP10', 'Yanggang-do', 'KP'),
	(1539, 'KP13', 'Nason', 'KP'),
	(1540, 'KR11', 'Seoul-teukbyeolsi', 'KR'),
	(1541, 'KR26', 'Busan-gwangyeoksi', 'KR'),
	(1542, 'KR27', 'Daegu-gwangyeoksi', 'KR'),
	(1543, 'KR28', 'Incheon-gwangyeoksi', 'KR'),
	(1544, 'KR29', 'Gwangju-gwangyeoksi', 'KR'),
	(1545, 'KR30', 'Daejeon-gwangyeoksi', 'KR'),
	(1546, 'KR31', 'Ulsan-gwangyeoksi', 'KR'),
	(1547, 'KR41', 'Gyeonggi-do', 'KR'),
	(1548, 'KR42', 'Gangwon-do', 'KR'),
	(1549, 'KR43', 'Chungcheongbuk-do', 'KR'),
	(1550, 'KR44', 'Chungcheongnam-do', 'KR'),
	(1551, 'KR45', 'Jeollabuk-do', 'KR'),
	(1552, 'KR46', 'Jeollanam-do', 'KR'),
	(1553, 'KR47', 'Gyeongsangbuk-do', 'KR'),
	(1554, 'KR48', 'Gyeongsangnam-do', 'KR'),
	(1555, 'KR49', 'Jeju-teukbyeoljachido', 'KR'),
	(1556, 'KWAH', 'Al Ahmadi', 'KW'),
	(1557, 'KWFA', 'Al Farwaniyah', 'KW'),
	(1558, 'KWHA', 'Hawalli', 'KW'),
	(1559, 'KWJA', 'Al Jahra', 'KW'),
	(1560, 'KWKU', 'Al Asimah', 'KW'),
	(1561, 'KWMU', 'Mubarak al Kabir', 'KW'),
	(1562, NULL, 'Cayman Islands', 'KY'),
	(1563, 'KZAKM', 'Aqmola oblysy', 'KZ'),
	(1564, 'KZAKT', 'Aqtobe oblysy', 'KZ'),
	(1565, 'KZALA', 'Almaty', 'KZ'),
	(1566, 'KZALM', 'Almaty oblysy', 'KZ'),
	(1567, 'KZAST', 'Astana', 'KZ'),
	(1568, 'KZATY', 'Atyrau oblysy', 'KZ'),
	(1569, 'KZBAY', 'Bayqongyr', 'KZ'),
	(1570, 'KZKAR', 'Qaraghandy oblysy', 'KZ'),
	(1571, 'KZKUS', 'Qostanay oblysy', 'KZ'),
	(1572, 'KZKZY', 'Qyzylorda oblysy', 'KZ'),
	(1573, 'KZMAN', 'Mangghystau oblysy', 'KZ'),
	(1574, 'KZPAV', 'Pavlodar oblysy', 'KZ'),
	(1575, 'KZSEV', 'Soltustik Qazaqstan oblysy', 'KZ'),
	(1576, 'KZVOS', 'Shyghys Qazaqstan oblysy', 'KZ'),
	(1577, 'KZYUZ', 'Ongtustik Qazaqstan oblysy', 'KZ'),
	(1578, 'KZZAP', 'Batys Qazaqstan oblysy', 'KZ'),
	(1579, 'KZZHA', 'Zhambyl oblysy', 'KZ'),
	(1580, 'LAAT', 'Attapu', 'LA'),
	(1581, 'LABK', 'Bokeo', 'LA'),
	(1582, 'LABL', 'Bolikhamxai', 'LA'),
	(1583, 'LACH', 'Champasak', 'LA'),
	(1584, 'LAHO', 'Houaphan', 'LA'),
	(1585, 'LAKH', 'Khammouan', 'LA'),
	(1586, 'LALM', 'Louang Namtha', 'LA'),
	(1587, 'LALP', 'Louangphabang', 'LA'),
	(1588, 'LAOU', 'Oudomxai', 'LA'),
	(1589, 'LAPH', 'Phongsali', 'LA'),
	(1590, 'LASL', 'Salavan', 'LA'),
	(1591, 'LASV', 'Savannakhet', 'LA'),
	(1592, 'LAVI', 'Viangchan', 'LA'),
	(1593, 'LAXA', 'Xaignabouli', 'LA'),
	(1594, 'LAXE', 'Xekong', 'LA'),
	(1595, 'LAXI', 'Xiangkhouang', 'LA'),
	(1596, 'LBAK', 'Aakkar', 'LB'),
	(1597, 'LBAS', 'Liban-Nord', 'LB'),
	(1598, 'LBBA', 'Beyrouth', 'LB'),
	(1599, 'LBBH', 'Baalbek-Hermel', 'LB'),
	(1600, 'LBBI', 'Beqaa', 'LB'),
	(1601, 'LBJA', 'Liban-Sud', 'LB'),
	(1602, 'LBJL', 'Mont-Liban', 'LB'),
	(1603, 'LBNA', 'Nabatiye', 'LB'),
	(1604, 'LC01', 'Anse la Raye', 'LC'),
	(1605, 'LC02', 'Castries', 'LC'),
	(1606, 'LC05', 'Dennery', 'LC'),
	(1607, 'LC06', 'Gros Islet', 'LC'),
	(1608, 'LC07', 'Laborie', 'LC'),
	(1609, 'LC08', 'Micoud', 'LC'),
	(1610, 'LC10', 'Soufriere', 'LC'),
	(1611, 'LC11', 'Vieux Fort', 'LC'),
	(1612, 'LI01', 'Balzers', 'LI'),
	(1613, 'LI02', 'Eschen', 'LI'),
	(1614, 'LI03', 'Gamprin', 'LI'),
	(1615, 'LI04', 'Mauren', 'LI'),
	(1616, 'LI05', 'Planken', 'LI'),
	(1617, 'LI06', 'Ruggell', 'LI'),
	(1618, 'LI07', 'Schaan', 'LI'),
	(1619, 'LI08', 'Schellenberg', 'LI'),
	(1620, 'LI09', 'Triesen', 'LI'),
	(1621, 'LI10', 'Triesenberg', 'LI'),
	(1622, 'LI11', 'Vaduz', 'LI'),
	(1623, 'LK1', 'Western Province', 'LK'),
	(1624, 'LK2', 'Central Province', 'LK'),
	(1625, 'LK3', 'Southern Province', 'LK'),
	(1626, 'LK4', 'Northern Province', 'LK'),
	(1627, 'LK5', 'Eastern Province', 'LK'),
	(1628, 'LK6', 'North Western Province', 'LK'),
	(1629, 'LK7', 'North Central Province', 'LK'),
	(1630, 'LK8', 'Uva Province', 'LK'),
	(1631, 'LK9', 'Sabaragamuwa Province', 'LK'),
	(1632, 'LRBG', 'Bong', 'LR'),
	(1633, 'LRBM', 'Bomi', 'LR'),
	(1634, 'LRCM', 'Grand Cape Mount', 'LR'),
	(1635, 'LRGB', 'Grand Bassa', 'LR'),
	(1636, 'LRGG', 'Grand Gedeh', 'LR'),
	(1637, 'LRGK', 'Grand Kru', 'LR'),
	(1638, 'LRGP', 'Gbarpolu', 'LR'),
	(1639, 'LRLO', 'Lofa', 'LR'),
	(1640, 'LRMG', 'Margibi', 'LR'),
	(1641, 'LRMO', 'Montserrado', 'LR'),
	(1642, 'LRMY', 'Maryland', 'LR'),
	(1643, 'LRNI', 'Nimba', 'LR'),
	(1644, 'LRRG', 'River Gee', 'LR'),
	(1645, 'LRRI', 'River Cess', 'LR'),
	(1646, 'LRSI', 'Sinoe', 'LR'),
	(1647, 'LSA', 'Maseru', 'LS'),
	(1648, 'LSB', 'Butha-Buthe', 'LS'),
	(1649, 'LSC', 'Leribe', 'LS'),
	(1650, 'LSD', 'Berea', 'LS'),
	(1651, 'LSE', 'Mafeteng', 'LS'),
	(1652, 'LSF', 'Mohales Hoek', 'LS'),
	(1653, 'LSG', 'Quthing', 'LS'),
	(1654, 'LSH', 'Qachas Nek', 'LS'),
	(1655, 'LSJ', 'Mokhotlong', 'LS'),
	(1656, 'LSK', 'Thaba-Tseka', 'LS'),
	(1657, 'LTAL', 'Alytaus apskritis', 'LT'),
	(1658, 'LTKL', 'Klaipedos apskritis', 'LT'),
	(1659, 'LTKU', 'Kauno apskritis', 'LT'),
	(1660, 'LTMR', 'Marijampoles apskritis', 'LT'),
	(1661, 'LTPN', 'Panevezio apskritis', 'LT'),
	(1662, 'LTSA', 'Siauliu apskritis', 'LT'),
	(1663, 'LTTA', 'Taurages apskritis', 'LT'),
	(1664, 'LTTE', 'Telsiu apskritis', 'LT'),
	(1665, 'LTUT', 'Utenos apskritis', 'LT'),
	(1666, 'LTVL', 'Vilniaus apskritis', 'LT'),
	(1667, 'LUDI', 'Diekirch', 'LU'),
	(1668, 'LUGR', 'Grevenmacher', 'LU'),
	(1669, 'LULU', 'Luxembourg', 'LU'),
	(1670, 'LV001', 'Aglonas novads', 'LV'),
	(1671, 'LV002', 'Aizkraukles novads', 'LV'),
	(1672, 'LV003', 'Aizputes novads', 'LV'),
	(1673, 'LV005', 'Alojas novads', 'LV'),
	(1674, 'LV007', 'Aluksnes novads', 'LV'),
	(1675, 'LV011', 'Adazu novads', 'LV'),
	(1676, 'LV012', 'Babites novads', 'LV'),
	(1677, 'LV014', 'Baltinavas novads', 'LV'),
	(1678, 'LV015', 'Balvu novads', 'LV'),
	(1679, 'LV016', 'Bauskas novads', 'LV'),
	(1680, 'LV017', 'Beverinas novads', 'LV'),
	(1681, 'LV018', 'Brocenu novads', 'LV'),
	(1682, 'LV020', 'Carnikavas novads', 'LV'),
	(1683, 'LV021', 'Cesvaines novads', 'LV'),
	(1684, 'LV022', 'Cesu novads', 'LV'),
	(1685, 'LV023', 'Ciblas novads', 'LV'),
	(1686, 'LV025', 'Daugavpils novads', 'LV'),
	(1687, 'LV026', 'Dobeles novads', 'LV'),
	(1688, 'LV027', 'Dundagas novads', 'LV'),
	(1689, 'LV033', 'Gulbenes novads', 'LV'),
	(1690, 'LV034', 'Iecavas novads', 'LV'),
	(1691, 'LV037', 'Incukalna novads', 'LV'),
	(1692, 'LV038', 'Jaunjelgavas novads', 'LV'),
	(1693, 'LV039', 'Jaunpiebalgas novads', 'LV'),
	(1694, 'LV040', 'Jaunpils novads', 'LV'),
	(1695, 'LV041', 'Jelgavas novads', 'LV'),
	(1696, 'LV042', 'Jekabpils novads', 'LV'),
	(1697, 'LV046', 'Kokneses novads', 'LV'),
	(1698, 'LV047', 'Kraslavas novads', 'LV'),
	(1699, 'LV050', 'Kuldigas novads', 'LV'),
	(1700, 'LV052', 'Kekavas novads', 'LV'),
	(1701, 'LV054', 'Limbazu novads', 'LV'),
	(1702, 'LV057', 'Lubanas novads', 'LV'),
	(1703, 'LV058', 'Ludzas novads', 'LV'),
	(1704, 'LV059', 'Madonas novads', 'LV'),
	(1705, 'LV061', 'Malpils novads', 'LV'),
	(1706, 'LV067', 'Ogres novads', 'LV'),
	(1707, 'LV068', 'Olaines novads', 'LV'),
	(1708, 'LV069', 'Ozolnieku novads', 'LV'),
	(1709, 'LV073', 'Preilu novads', 'LV'),
	(1710, 'LV077', 'Rezeknes novads', 'LV'),
	(1711, 'LV079', 'Rojas novads', 'LV'),
	(1712, 'LV080', 'Ropazu novads', 'LV'),
	(1713, 'LV082', 'Rugaju novads', 'LV'),
	(1714, 'LV083', 'Rundales novads', 'LV'),
	(1715, 'LV086', 'Salacgrivas novads', 'LV'),
	(1716, 'LV088', 'Saldus novads', 'LV'),
	(1717, 'LV090', 'Sejas novads', 'LV'),
	(1718, 'LV091', 'Siguldas novads', 'LV'),
	(1719, 'LV093', 'Skrundas novads', 'LV'),
	(1720, 'LV095', 'Stopinu novads', 'LV'),
	(1721, 'LV096', 'Strencu novads', 'LV'),
	(1722, 'LV097', 'Talsu novads', 'LV'),
	(1723, 'LV099', 'Tukuma novads', 'LV'),
	(1724, 'LV100', 'Vainodes novads', 'LV'),
	(1725, 'LV101', 'Valkas novads', 'LV'),
	(1726, 'LV103', 'Varkavas novads', 'LV'),
	(1727, 'LV105', 'Vecumnieku novads', 'LV'),
	(1728, 'LV106', 'Ventspils novads', 'LV'),
	(1729, 'LVJEL', 'Jelgava', 'LV'),
	(1730, 'LVJUR', 'Jurmala', 'LV'),
	(1731, 'LVLPX', 'Liepaja', 'LV'),
	(1732, 'LVRIX', 'Riga', 'LV'),
	(1733, 'LVVMR', 'Valmiera', 'LV'),
	(1734, 'LYBA', 'Banghazi', 'LY'),
	(1735, 'LYBU', 'Al Butnan', 'LY'),
	(1736, 'LYDR', 'Darnah', 'LY'),
	(1737, 'LYGT', 'Ghat', 'LY'),
	(1738, 'LYJA', 'Al Jabal al Akhdar', 'LY'),
	(1739, 'LYJG', 'Al Jabal al Gharbi', 'LY'),
	(1740, 'LYJI', 'Al Jafarah', 'LY'),
	(1741, 'LYJU', 'Al Jufrah', 'LY'),
	(1742, 'LYKF', 'Al Kufrah', 'LY'),
	(1743, 'LYMB', 'Al Marqab', 'LY'),
	(1744, 'LYMI', 'Misratah', 'LY'),
	(1745, 'LYMJ', 'Al Marj', 'LY'),
	(1746, 'LYMQ', 'Murzuq', 'LY'),
	(1747, 'LYNL', 'Nalut', 'LY'),
	(1748, 'LYNQ', 'An Nuqat al Khams', 'LY'),
	(1749, 'LYSB', 'Sabha', 'LY'),
	(1750, 'LYSR', 'Surt', 'LY');
INSERT INTO public.sehir VALUES
	(1751, 'LYTB', 'Tarabulus', 'LY'),
	(1752, 'LYWA', 'Al Wahat', 'LY'),
	(1753, 'LYWD', 'Wadi al Hayat', 'LY'),
	(1754, 'LYWS', 'Wadi ash Shati', 'LY'),
	(1755, 'LYZA', 'Az Zawiyah', 'LY'),
	(1756, 'MA01', 'Tanger-Tetouan', 'MA'),
	(1757, 'MA02', 'Gharb-Chrarda-Beni Hssen', 'MA'),
	(1758, 'MA03', 'Taza-Al Hoceima-Taounate', 'MA'),
	(1759, 'MA04', 'LOriental', 'MA'),
	(1760, 'MA05', 'Fes-Boulemane', 'MA'),
	(1761, 'MA06', 'Meknes-Tafilalet', 'MA'),
	(1762, 'MA07', 'Rabat-Sale-Zemmour-Zaer', 'MA'),
	(1763, 'MA08', 'Grand Casablanca', 'MA'),
	(1764, 'MA09', 'Chaouia-Ouardigha', 'MA'),
	(1765, 'MA10', 'Doukhala-Abda', 'MA'),
	(1766, 'MA11', 'Marrakech-Tensift-Al Haouz', 'MA'),
	(1767, 'MA12', 'Tadla-Azilal', 'MA'),
	(1768, 'MA13', 'Souss-Massa-Draa', 'MA'),
	(1769, 'MA14', 'Guelmim-Es Semara', 'MA'),
	(1770, 'MCCO', 'La Condamine', 'MC'),
	(1771, 'MCFO', 'Fontvieille', 'MC'),
	(1772, 'MCMC', 'Monte-Carlo', 'MC'),
	(1773, 'MCMG', 'Moneghetti', 'MC'),
	(1774, 'MCMO', 'Monaco-Ville', 'MC'),
	(1775, 'MCSR', 'Saint-Roman', 'MC'),
	(1776, 'MDAN', 'Anenii Noi', 'MD'),
	(1777, 'MDBA', 'Balti', 'MD'),
	(1778, 'MDBD', 'Bender', 'MD'),
	(1779, 'MDBR', 'Briceni', 'MD'),
	(1780, 'MDBS', 'Basarabeasca', 'MD'),
	(1781, 'MDCA', 'Cahul', 'MD'),
	(1782, 'MDCL', 'Calarasi', 'MD'),
	(1783, 'MDCM', 'Cimislia', 'MD'),
	(1784, 'MDCR', 'Criuleni', 'MD'),
	(1785, 'MDCS', 'Causeni', 'MD'),
	(1786, 'MDCT', 'Cantemir', 'MD'),
	(1787, 'MDCU', 'Chisinau', 'MD'),
	(1788, 'MDDO', 'Donduseni', 'MD'),
	(1789, 'MDDR', 'Drochia', 'MD'),
	(1790, 'MDDU', 'Dubasari', 'MD'),
	(1791, 'MDED', 'Edinet', 'MD'),
	(1792, 'MDFA', 'Falesti', 'MD'),
	(1793, 'MDFL', 'Floresti', 'MD'),
	(1794, 'MDGA', 'Gagauzia, Unitatea teritoriala autonoma', 'MD'),
	(1795, 'MDGL', 'Glodeni', 'MD'),
	(1796, 'MDHI', 'Hincesti', 'MD'),
	(1797, 'MDIA', 'Ialoveni', 'MD'),
	(1798, 'MDLE', 'Leova', 'MD'),
	(1799, 'MDNI', 'Nisporeni', 'MD'),
	(1800, 'MDOC', 'Ocnita', 'MD'),
	(1801, 'MDOR', 'Orhei', 'MD'),
	(1802, 'MDRE', 'Rezina', 'MD'),
	(1803, 'MDRI', 'Riscani', 'MD'),
	(1804, 'MDSD', 'Soldanesti', 'MD'),
	(1805, 'MDSI', 'Singerei', 'MD'),
	(1806, 'MDSN', 'Stinga Nistrului, unitatea teritoriala din', 'MD'),
	(1807, 'MDSO', 'Soroca', 'MD'),
	(1808, 'MDST', 'Straseni', 'MD'),
	(1809, 'MDSV', 'Stefan Voda', 'MD'),
	(1810, 'MDTA', 'Taraclia', 'MD'),
	(1811, 'MDTE', 'Telenesti', 'MD'),
	(1812, 'MDUN', 'Ungheni', 'MD'),
	(1813, 'ME02', 'Bar', 'ME'),
	(1814, 'ME05', 'Budva', 'ME'),
	(1815, 'ME06', 'Cetinje', 'ME'),
	(1816, 'ME07', 'Danilovgrad', 'ME'),
	(1817, 'ME08', 'Herceg-Novi', 'ME'),
	(1818, 'ME09', 'Kolasin', 'ME'),
	(1819, 'ME10', 'Kotor', 'ME'),
	(1820, 'ME11', 'Mojkovac', 'ME'),
	(1821, 'ME12', 'Niksic', 'ME'),
	(1822, 'ME16', 'Podgorica', 'ME'),
	(1823, 'ME19', 'Tivat', 'ME'),
	(1824, 'ME20', 'Ulcinj', 'ME'),
	(1825, 'ME21', 'Zabljak', 'ME'),
	(1826, NULL, 'Saint Martin', 'MF'),
	(1827, 'MGA', 'Toamasina', 'MG'),
	(1828, 'MGD', 'Antsiranana', 'MG'),
	(1829, 'MGF', 'Fianarantsoa', 'MG'),
	(1830, 'MGM', 'Mahajanga', 'MG'),
	(1831, 'MGT', 'Antananarivo', 'MG'),
	(1832, 'MGU', 'Toliara', 'MG'),
	(1833, 'MHALK', 'Ailuk', 'MH'),
	(1834, 'MHALL', 'Ailinglaplap', 'MH'),
	(1835, 'MHARN', 'Arno', 'MH'),
	(1836, 'MHAUR', 'Aur', 'MH'),
	(1837, 'MHEBO', 'Ebon', 'MH'),
	(1838, 'MHENI', 'Enewetak and Ujelang', 'MH'),
	(1839, 'MHJAB', 'Jabat', 'MH'),
	(1840, 'MHJAL', 'Jaluit', 'MH'),
	(1841, 'MHKIL', 'Bikini and Kili', 'MH'),
	(1842, 'MHKWA', 'Kwajalein', 'MH'),
	(1843, 'MHLAE', 'Lae', 'MH'),
	(1844, 'MHLIB', 'Lib', 'MH'),
	(1845, 'MHLIK', 'Likiep', 'MH'),
	(1846, 'MHMAJ', 'Majuro', 'MH'),
	(1847, 'MHMAL', 'Maloelap', 'MH'),
	(1848, 'MHMEJ', 'Mejit', 'MH'),
	(1849, 'MHMIL', 'Mili', 'MH'),
	(1850, 'MHNMK', 'Namdrik', 'MH'),
	(1851, 'MHNMU', 'Namu', 'MH'),
	(1852, 'MHRON', 'Rongelap', 'MH'),
	(1853, 'MHUJA', 'Ujae', 'MH'),
	(1854, 'MHUTI', 'Utrik', 'MH'),
	(1855, 'MHWTH', 'Wotho', 'MH'),
	(1856, 'MHWTJ', 'Wotje', 'MH'),
	(1857, 'MK02', 'Aracinovo', 'MK'),
	(1858, 'MK03', 'Berovo', 'MK'),
	(1859, 'MK04', 'Bitola', 'MK'),
	(1860, 'MK05', 'Bogdanci', 'MK'),
	(1861, 'MK06', 'Bogovinje', 'MK'),
	(1862, 'MK07', 'Bosilovo', 'MK'),
	(1863, 'MK08', 'Brvenica', 'MK'),
	(1864, 'MK10', 'Valandovo', 'MK'),
	(1865, 'MK11', 'Vasilevo', 'MK'),
	(1866, 'MK12', 'Vevcani', 'MK'),
	(1867, 'MK13', 'Veles', 'MK'),
	(1868, 'MK14', 'Vinica', 'MK'),
	(1869, 'MK16', 'Vrapciste', 'MK'),
	(1870, 'MK18', 'Gevgelija', 'MK'),
	(1871, 'MK19', 'Gostivar', 'MK'),
	(1872, 'MK20', 'Gradsko', 'MK'),
	(1873, 'MK21', 'Debar', 'MK'),
	(1874, 'MK22', 'Debarca', 'MK'),
	(1875, 'MK23', 'Delcevo', 'MK'),
	(1876, 'MK24', 'Demir Kapija', 'MK'),
	(1877, 'MK25', 'Demir Hisar', 'MK'),
	(1878, 'MK26', 'Dojran', 'MK'),
	(1879, 'MK27', 'Dolneni', 'MK'),
	(1880, 'MK30', 'Zelino', 'MK'),
	(1881, 'MK32', 'Zelenikovo', 'MK'),
	(1882, 'MK33', 'Zrnovci', 'MK'),
	(1883, 'MK34', 'Ilinden', 'MK'),
	(1884, 'MK35', 'Jegunovce', 'MK'),
	(1885, 'MK36', 'Kavadarci', 'MK'),
	(1886, 'MK37', 'Karbinci', 'MK'),
	(1887, 'MK40', 'Kicevo', 'MK'),
	(1888, 'MK41', 'Konce', 'MK'),
	(1889, 'MK42', 'Kocani', 'MK'),
	(1890, 'MK43', 'Kratovo', 'MK'),
	(1891, 'MK44', 'Kriva Palanka', 'MK'),
	(1892, 'MK45', 'Krivogastani', 'MK'),
	(1893, 'MK46', 'Krusevo', 'MK'),
	(1894, 'MK47', 'Kumanovo', 'MK'),
	(1895, 'MK48', 'Lipkovo', 'MK'),
	(1896, 'MK49', 'Lozovo', 'MK'),
	(1897, 'MK50', 'Mavrovo i Rostusa', 'MK'),
	(1898, 'MK51', 'Makedonska Kamenica', 'MK'),
	(1899, 'MK52', 'Makedonski Brod', 'MK'),
	(1900, 'MK53', 'Mogila', 'MK'),
	(1901, 'MK54', 'Negotino', 'MK'),
	(1902, 'MK55', 'Novaci', 'MK'),
	(1903, 'MK56', 'Novo Selo', 'MK'),
	(1904, 'MK58', 'Ohrid', 'MK'),
	(1905, 'MK59', 'Petrovec', 'MK'),
	(1906, 'MK60', 'Pehcevo', 'MK'),
	(1907, 'MK61', 'Plasnica', 'MK'),
	(1908, 'MK62', 'Prilep', 'MK'),
	(1909, 'MK63', 'Probistip', 'MK'),
	(1910, 'MK64', 'Radovis', 'MK'),
	(1911, 'MK65', 'Rankovce', 'MK'),
	(1912, 'MK66', 'Resen', 'MK'),
	(1913, 'MK67', 'Rosoman', 'MK'),
	(1914, 'MK69', 'Sveti Nikole', 'MK'),
	(1915, 'MK70', 'Sopiste', 'MK'),
	(1916, 'MK71', 'Staro Nagoricane', 'MK'),
	(1917, 'MK72', 'Struga', 'MK'),
	(1918, 'MK73', 'Strumica', 'MK'),
	(1919, 'MK74', 'Studenicani', 'MK'),
	(1920, 'MK75', 'Tearce', 'MK'),
	(1921, 'MK76', 'Tetovo', 'MK'),
	(1922, 'MK78', 'Centar Zupa', 'MK'),
	(1923, 'MK80', 'Caska', 'MK'),
	(1924, 'MK81', 'Cesinovo-Oblesevo', 'MK'),
	(1925, 'MK82', 'Cucer Sandevo', 'MK'),
	(1926, 'MK83', 'Stip', 'MK'),
	(1927, 'MK85', 'Skopje', 'MK'),
	(1928, 'ML1', 'Kayes', 'ML'),
	(1929, 'ML2', 'Koulikoro', 'ML'),
	(1930, 'ML3', 'Sikasso', 'ML'),
	(1931, 'ML4', 'Segou', 'ML'),
	(1932, 'ML5', 'Mopti', 'ML'),
	(1933, 'ML6', 'Tombouctou', 'ML'),
	(1934, 'ML7', 'Gao', 'ML'),
	(1935, 'ML8', 'Kidal', 'ML'),
	(1936, 'MLBKO', 'Bamako', 'ML'),
	(1937, 'MM01', 'Sagaing', 'MM'),
	(1938, 'MM02', 'Bago', 'MM'),
	(1939, 'MM03', 'Magway', 'MM'),
	(1940, 'MM04', 'Mandalay', 'MM'),
	(1941, 'MM05', 'Tanintharyi', 'MM'),
	(1942, 'MM06', 'Yangon', 'MM'),
	(1943, 'MM07', 'Ayeyarwady', 'MM'),
	(1944, 'MM11', 'Kachin', 'MM'),
	(1945, 'MM12', 'Kayah', 'MM'),
	(1946, 'MM13', 'Kayin', 'MM'),
	(1947, 'MM14', 'Chin', 'MM'),
	(1948, 'MM15', 'Mon', 'MM'),
	(1949, 'MM16', 'Rakhine', 'MM'),
	(1950, 'MM17', 'Shan', 'MM'),
	(1951, 'MM18', 'Nay Pyi Taw', 'MM'),
	(1952, 'MN035', 'Orhon', 'MN'),
	(1953, 'MN037', 'Darhan uul', 'MN'),
	(1954, 'MN039', 'Hentiy', 'MN'),
	(1955, 'MN041', 'Hovsgol', 'MN'),
	(1956, 'MN043', 'Hovd', 'MN'),
	(1957, 'MN046', 'Uvs', 'MN'),
	(1958, 'MN047', 'Tov', 'MN'),
	(1959, 'MN049', 'Selenge', 'MN'),
	(1960, 'MN051', 'Suhbaatar', 'MN'),
	(1961, 'MN053', 'Omnogovi', 'MN'),
	(1962, 'MN055', 'Ovorhangay', 'MN'),
	(1963, 'MN057', 'Dzavhan', 'MN'),
	(1964, 'MN059', 'Dundgovi', 'MN'),
	(1965, 'MN061', 'Dornod', 'MN'),
	(1966, 'MN063', 'Dornogovi', 'MN'),
	(1967, 'MN064', 'Govi-Sumber', 'MN'),
	(1968, 'MN065', 'Govi-Altay', 'MN'),
	(1969, 'MN067', 'Bulgan', 'MN'),
	(1970, 'MN069', 'Bayanhongor', 'MN'),
	(1971, 'MN071', 'Bayan-Olgiy', 'MN'),
	(1972, 'MN073', 'Arhangay', 'MN'),
	(1973, 'MN1', 'Ulaanbaatar', 'MN'),
	(1974, NULL, 'Macau', 'MO'),
	(1975, NULL, 'Northern Mariana Islands', 'MP'),
	(1976, NULL, 'Martinique', 'MQ'),
	(1977, 'MR01', 'Hodh ech Chargui', 'MR'),
	(1978, 'MR02', 'Hodh el Gharbi', 'MR'),
	(1979, 'MR03', 'Assaba', 'MR'),
	(1980, 'MR04', 'Gorgol', 'MR'),
	(1981, 'MR05', 'Brakna', 'MR'),
	(1982, 'MR06', 'Trarza', 'MR'),
	(1983, 'MR07', 'Adrar', 'MR'),
	(1984, 'MR08', 'Dakhlet Nouadhibou', 'MR'),
	(1985, 'MR09', 'Tagant', 'MR'),
	(1986, 'MR10', 'Guidimaka', 'MR'),
	(1987, 'MR11', 'Tiris Zemmour', 'MR'),
	(1988, 'MR12', 'Inchiri', 'MR'),
	(1989, 'MR14', 'Nouakchott Nord', 'MR'),
	(1990, NULL, 'Saint Anthony', 'MS'),
	(1991, NULL, 'Saint Peter', 'MS'),
	(1992, 'MT01', 'Attard', 'MT'),
	(1993, 'MT02', 'Balzan', 'MT'),
	(1994, 'MT03', 'Birgu', 'MT'),
	(1995, 'MT04', 'Birkirkara', 'MT'),
	(1996, 'MT05', 'Birzebbuga', 'MT'),
	(1997, 'MT06', 'Bormla', 'MT'),
	(1998, 'MT07', 'Dingli', 'MT'),
	(1999, 'MT08', 'Fgura', 'MT'),
	(2000, 'MT09', 'Floriana', 'MT');
INSERT INTO public.sehir VALUES
	(2001, 'MT11', 'Gudja', 'MT'),
	(2002, 'MT13', 'Ghajnsielem', 'MT'),
	(2003, 'MT15', 'Gharghur', 'MT'),
	(2004, 'MT17', 'Ghaxaq', 'MT'),
	(2005, 'MT18', 'Hamrun', 'MT'),
	(2006, 'MT19', 'Iklin', 'MT'),
	(2007, 'MT20', 'Isla', 'MT'),
	(2008, 'MT21', 'Kalkara', 'MT'),
	(2009, 'MT22', 'Kercem', 'MT'),
	(2010, 'MT23', 'Kirkop', 'MT'),
	(2011, 'MT24', 'Lija', 'MT'),
	(2012, 'MT25', 'Luqa', 'MT'),
	(2013, 'MT26', 'Marsa', 'MT'),
	(2014, 'MT28', 'Marsaxlokk', 'MT'),
	(2015, 'MT30', 'Mellieha', 'MT'),
	(2016, 'MT32', 'Mosta', 'MT'),
	(2017, 'MT33', 'Mqabba', 'MT'),
	(2018, 'MT34', 'Msida', 'MT'),
	(2019, 'MT37', 'Nadur', 'MT'),
	(2020, 'MT38', 'Naxxar', 'MT'),
	(2021, 'MT39', 'Paola', 'MT'),
	(2022, 'MT42', 'Qala', 'MT'),
	(2023, 'MT43', 'Qormi', 'MT'),
	(2024, 'MT44', 'Qrendi', 'MT'),
	(2025, 'MT45', 'Rabat Gozo', 'MT'),
	(2026, 'MT46', 'Rabat Malta', 'MT'),
	(2027, 'MT47', 'Safi', 'MT'),
	(2028, 'MT48', 'Saint Julian', 'MT'),
	(2029, 'MT49', 'Saint John', 'MT'),
	(2030, 'MT51', 'Saint Pauls Bay', 'MT'),
	(2031, 'MT52', 'Sannat', 'MT'),
	(2032, 'MT53', 'Saint Lucia', 'MT'),
	(2033, 'MT54', 'Saint Venera', 'MT'),
	(2034, 'MT55', 'Siggiewi', 'MT'),
	(2035, 'MT56', 'Sliema', 'MT'),
	(2036, 'MT57', 'Swieqi', 'MT'),
	(2037, 'MT58', 'Ta Xbiex', 'MT'),
	(2038, 'MT59', 'Tarxien', 'MT'),
	(2039, 'MT60', 'Valletta', 'MT'),
	(2040, 'MT61', 'Xaghra', 'MT'),
	(2041, 'MT62', 'Xewkija', 'MT'),
	(2042, 'MT64', 'Haz-Zabbar', 'MT'),
	(2043, 'MT65', 'Zebbug Gozo', 'MT'),
	(2044, 'MT67', 'Zejtun', 'MT'),
	(2045, 'MT68', 'Zurrieq', 'MT'),
	(2046, 'MUBL', 'Black River', 'MU'),
	(2047, 'MUFL', 'Flacq', 'MU'),
	(2048, 'MUGP', 'Grand Port', 'MU'),
	(2049, 'MUMO', 'Moka', 'MU'),
	(2050, 'MUPA', 'Pamplemousses', 'MU'),
	(2051, 'MUPU', 'Port Louis', 'MU'),
	(2052, 'MUPW', 'Plaines Wilhems', 'MU'),
	(2053, 'MURR', 'Riviere du Rempart', 'MU'),
	(2054, 'MUSA', 'Savanne', 'MU'),
	(2055, 'MV01', 'Seenu', 'MV'),
	(2056, 'MV02', 'Alifu Alifu', 'MV'),
	(2057, 'MV05', 'Laamu', 'MV'),
	(2058, 'MV07', 'Haa Alifu', 'MV'),
	(2059, 'MV08', 'Thaa', 'MV'),
	(2060, 'MV12', 'Meemu', 'MV'),
	(2061, 'MV13', 'Raa', 'MV'),
	(2062, 'MV17', 'Dhaalu', 'MV'),
	(2063, 'MV20', 'Baa', 'MV'),
	(2064, 'MV23', 'Haa Dhaalu', 'MV'),
	(2065, 'MV24', 'Shaviyani', 'MV'),
	(2066, 'MV25', 'Noonu', 'MV'),
	(2067, 'MV26', 'Kaafu', 'MV'),
	(2068, 'MV28', 'Gaafu Dhaalu', 'MV'),
	(2069, 'MVMLE', 'Maale', 'MV'),
	(2070, 'MWBA', 'Balaka', 'MW'),
	(2071, 'MWBL', 'Blantyre', 'MW'),
	(2072, 'MWCK', 'Chikwawa', 'MW'),
	(2073, 'MWCR', 'Chiradzulu', 'MW'),
	(2074, 'MWCT', 'Chitipa', 'MW'),
	(2075, 'MWDE', 'Dedza', 'MW'),
	(2076, 'MWDO', 'Dowa', 'MW'),
	(2077, 'MWKR', 'Karonga', 'MW'),
	(2078, 'MWKS', 'Kasungu', 'MW'),
	(2079, 'MWLI', 'Lilongwe', 'MW'),
	(2080, 'MWLK', 'Likoma', 'MW'),
	(2081, 'MWMC', 'Mchinji', 'MW'),
	(2082, 'MWMG', 'Mangochi', 'MW'),
	(2083, 'MWMH', 'Machinga', 'MW'),
	(2084, 'MWMU', 'Mulanje', 'MW'),
	(2085, 'MWMW', 'Mwanza', 'MW'),
	(2086, 'MWMZ', 'Mzimba', 'MW'),
	(2087, 'MWNB', 'Nkhata Bay', 'MW'),
	(2088, 'MWNE', 'Neno', 'MW'),
	(2089, 'MWNI', 'Ntchisi', 'MW'),
	(2090, 'MWNK', 'Nkhotakota', 'MW'),
	(2091, 'MWNS', 'Nsanje', 'MW'),
	(2092, 'MWNU', 'Ntcheu', 'MW'),
	(2093, 'MWPH', 'Phalombe', 'MW'),
	(2094, 'MWRU', 'Rumphi', 'MW'),
	(2095, 'MWSA', 'Salima', 'MW'),
	(2096, 'MWTH', 'Thyolo', 'MW'),
	(2097, 'MWZO', 'Zomba', 'MW'),
	(2098, 'MXAGU', 'Aguascalientes', 'MX'),
	(2099, 'MXBCN', 'Baja California', 'MX'),
	(2100, 'MXBCS', 'Baja California Sur', 'MX'),
	(2101, 'MXCAM', 'Campeche', 'MX'),
	(2102, 'MXCHH', 'Chihuahua', 'MX'),
	(2103, 'MXCHP', 'Chiapas', 'MX'),
	(2104, 'MXCMX', 'Ciudad de Mexico', 'MX'),
	(2105, 'MXCOA', 'Coahuila de Zaragoza', 'MX'),
	(2106, 'MXCOL', 'Colima', 'MX'),
	(2107, 'MXDUR', 'Durango', 'MX'),
	(2108, 'MXGRO', 'Guerrero', 'MX'),
	(2109, 'MXGUA', 'Guanajuato', 'MX'),
	(2110, 'MXHID', 'Hidalgo', 'MX'),
	(2111, 'MXJAL', 'Jalisco', 'MX'),
	(2112, 'MXMEX', 'Mexico', 'MX'),
	(2113, 'MXMIC', 'Michoacan de Ocampo', 'MX'),
	(2114, 'MXMOR', 'Morelos', 'MX'),
	(2115, 'MXNAY', 'Nayarit', 'MX'),
	(2116, 'MXNLE', 'Nuevo Leon', 'MX'),
	(2117, 'MXPUE', 'Puebla', 'MX'),
	(2118, 'MXQUE', 'Queretaro', 'MX'),
	(2119, 'MXROO', 'Quintana Roo', 'MX'),
	(2120, 'MXSIN', 'Sinaloa', 'MX'),
	(2121, 'MXSLP', 'San Luis Potosi', 'MX'),
	(2122, 'MXSON', 'Sonora', 'MX'),
	(2123, 'MXTAB', 'Tabasco', 'MX'),
	(2124, 'MXTAM', 'Tamaulipas', 'MX'),
	(2125, 'MXTLA', 'Tlaxcala', 'MX'),
	(2126, 'MXVER', 'Veracruz de Ignacio de la Llave', 'MX'),
	(2127, 'MXYUC', 'Yucatan', 'MX'),
	(2128, 'MXZAC', 'Zacatecas', 'MX'),
	(2129, 'MY01', 'Johor', 'MY'),
	(2130, 'MY02', 'Kedah', 'MY'),
	(2131, 'MY03', 'Kelantan', 'MY'),
	(2132, 'MY04', 'Melaka', 'MY'),
	(2133, 'MY05', 'Negeri Sembilan', 'MY'),
	(2134, 'MY06', 'Pahang', 'MY'),
	(2135, 'MY07', 'Pulau Pinang', 'MY'),
	(2136, 'MY08', 'Perak', 'MY'),
	(2137, 'MY09', 'Perlis', 'MY'),
	(2138, 'MY10', 'Selangor', 'MY'),
	(2139, 'MY11', 'Terengganu', 'MY'),
	(2140, 'MY12', 'Sabah', 'MY'),
	(2141, 'MY13', 'Sarawak', 'MY'),
	(2142, 'MY14', 'Wilayah Persekutuan Kuala Lumpur', 'MY'),
	(2143, 'MY15', 'Wilayah Persekutuan Labuan', 'MY'),
	(2144, 'MY16', 'Wilayah Persekutuan Putrajaya', 'MY'),
	(2145, 'MZA', 'Niassa', 'MZ'),
	(2146, 'MZB', 'Manica', 'MZ'),
	(2147, 'MZG', 'Gaza', 'MZ'),
	(2148, 'MZI', 'Inhambane', 'MZ'),
	(2149, 'MZMPM', 'Maputo', 'MZ'),
	(2150, 'MZN', 'Nampula', 'MZ'),
	(2151, 'MZP', 'Cabo Delgado', 'MZ'),
	(2152, 'MZQ', 'Zambezia', 'MZ'),
	(2153, 'MZS', 'Sofala', 'MZ'),
	(2154, 'MZT', 'Tete', 'MZ'),
	(2155, 'NACA', 'Zambezi', 'NA'),
	(2156, 'NAER', 'Erongo', 'NA'),
	(2157, 'NAHA', 'Hardap', 'NA'),
	(2158, 'NAKA', 'Karas', 'NA'),
	(2159, 'NAKE', 'Kavango East', 'NA'),
	(2160, 'NAKH', 'Khomas', 'NA'),
	(2161, 'NAKU', 'Kunene', 'NA'),
	(2162, 'NAOD', 'Otjozondjupa', 'NA'),
	(2163, 'NAOH', 'Omaheke', 'NA'),
	(2164, 'NAON', 'Oshana', 'NA'),
	(2165, 'NAOS', 'Omusati', 'NA'),
	(2166, 'NAOT', 'Oshikoto', 'NA'),
	(2167, 'NAOW', 'Ohangwena', 'NA'),
	(2168, NULL, 'Province des iles Loyaute', 'NC'),
	(2169, NULL, 'Province Nord', 'NC'),
	(2170, NULL, 'Province Sud', 'NC'),
	(2171, 'NE1', 'Agadez', 'NE'),
	(2172, 'NE2', 'Diffa', 'NE'),
	(2173, 'NE3', 'Dosso', 'NE'),
	(2174, 'NE4', 'Maradi', 'NE'),
	(2175, 'NE5', 'Tahoua', 'NE'),
	(2176, 'NE6', 'Tillaberi', 'NE'),
	(2177, 'NE7', 'Zinder', 'NE'),
	(2178, 'NE8', 'Niamey', 'NE'),
	(2179, NULL, 'Norfolk Island', 'NF'),
	(2180, 'NGAB', 'Abia', 'NG'),
	(2181, 'NGAD', 'Adamawa', 'NG'),
	(2182, 'NGAK', 'Akwa Ibom', 'NG'),
	(2183, 'NGAN', 'Anambra', 'NG'),
	(2184, 'NGBA', 'Bauchi', 'NG'),
	(2185, 'NGBE', 'Benue', 'NG'),
	(2186, 'NGBO', 'Borno', 'NG'),
	(2187, 'NGBY', 'Bayelsa', 'NG'),
	(2188, 'NGCR', 'Cross River', 'NG'),
	(2189, 'NGDE', 'Delta', 'NG'),
	(2190, 'NGEB', 'Ebonyi', 'NG'),
	(2191, 'NGED', 'Edo', 'NG'),
	(2192, 'NGEK', 'Ekiti', 'NG'),
	(2193, 'NGEN', 'Enugu', 'NG'),
	(2194, 'NGFC', 'Abuja Federal Capital Territory', 'NG'),
	(2195, 'NGGO', 'Gombe', 'NG'),
	(2196, 'NGIM', 'Imo', 'NG'),
	(2197, 'NGJI', 'Jigawa', 'NG'),
	(2198, 'NGKD', 'Kaduna', 'NG'),
	(2199, 'NGKE', 'Kebbi', 'NG'),
	(2200, 'NGKN', 'Kano', 'NG'),
	(2201, 'NGKO', 'Kogi', 'NG'),
	(2202, 'NGKT', 'Katsina', 'NG'),
	(2203, 'NGKW', 'Kwara', 'NG'),
	(2204, 'NGLA', 'Lagos', 'NG'),
	(2205, 'NGNA', 'Nasarawa', 'NG'),
	(2206, 'NGNI', 'Niger', 'NG'),
	(2207, 'NGOG', 'Ogun', 'NG'),
	(2208, 'NGON', 'Ondo', 'NG'),
	(2209, 'NGOS', 'Osun', 'NG'),
	(2210, 'NGOY', 'Oyo', 'NG'),
	(2211, 'NGPL', 'Plateau', 'NG'),
	(2212, 'NGRI', 'Rivers', 'NG'),
	(2213, 'NGSO', 'Sokoto', 'NG'),
	(2214, 'NGTA', 'Taraba', 'NG'),
	(2215, 'NGYO', 'Yobe', 'NG'),
	(2216, 'NGZA', 'Zamfara', 'NG'),
	(2217, 'NIAN', 'Atlantico Norte', 'NI'),
	(2218, 'NIAS', 'Atlantico Sur', 'NI'),
	(2219, 'NIBO', 'Boaco', 'NI'),
	(2220, 'NICA', 'Carazo', 'NI'),
	(2221, 'NICI', 'Chinandega', 'NI'),
	(2222, 'NICO', 'Chontales', 'NI'),
	(2223, 'NIES', 'Esteli', 'NI'),
	(2224, 'NIGR', 'Granada', 'NI'),
	(2225, 'NIJI', 'Jinotega', 'NI'),
	(2226, 'NILE', 'Leon', 'NI'),
	(2227, 'NIMD', 'Madriz', 'NI'),
	(2228, 'NIMN', 'Managua', 'NI'),
	(2229, 'NIMS', 'Masaya', 'NI'),
	(2230, 'NIMT', 'Matagalpa', 'NI'),
	(2231, 'NINS', 'Nueva Segovia', 'NI'),
	(2232, 'NIRI', 'Rivas', 'NI'),
	(2233, 'NISJ', 'Rio San Juan', 'NI'),
	(2234, 'NLDR', 'Drenthe', 'NL'),
	(2235, 'NLFL', 'Flevoland', 'NL'),
	(2236, 'NLFR', 'Fryslan', 'NL'),
	(2237, 'NLGE', 'Gelderland', 'NL'),
	(2238, 'NLGR', 'Groningen', 'NL'),
	(2239, 'NLLI', 'Limburg', 'NL'),
	(2240, 'NLNB', 'Noord-Brabant', 'NL'),
	(2241, 'NLNH', 'Noord-Holland', 'NL'),
	(2242, 'NLOV', 'Overijssel', 'NL'),
	(2243, 'NLUT', 'Utrecht', 'NL'),
	(2244, 'NLZE', 'Zeeland', 'NL'),
	(2245, 'NLZH', 'Zuid-Holland', 'NL'),
	(2246, 'NO01', 'Ostfold', 'NO'),
	(2247, 'NO02', 'Akershus', 'NO'),
	(2248, 'NO03', 'Oslo', 'NO'),
	(2249, 'NO04', 'Hedmark', 'NO'),
	(2250, 'NO05', 'Oppland', 'NO');
INSERT INTO public.sehir VALUES
	(2251, 'NO06', 'Buskerud', 'NO'),
	(2252, 'NO07', 'Vestfold', 'NO'),
	(2253, 'NO08', 'Telemark', 'NO'),
	(2254, 'NO09', 'Aust-Agder', 'NO'),
	(2255, 'NO10', 'Vest-Agder', 'NO'),
	(2256, 'NO11', 'Rogaland', 'NO'),
	(2257, 'NO12', 'Hordaland', 'NO'),
	(2258, 'NO14', 'Sogn og Fjordane', 'NO'),
	(2259, 'NO15', 'More og Romsdal', 'NO'),
	(2260, 'NO16', 'Sor-Trondelag', 'NO'),
	(2261, 'NO17', 'Nord-Trondelag', 'NO'),
	(2262, 'NO18', 'Nordland', 'NO'),
	(2263, 'NO19', 'Troms', 'NO'),
	(2264, 'NO20', 'Finnmark', 'NO'),
	(2265, 'NPBA', 'Bagmati', 'NP'),
	(2266, 'NPBH', 'Bheri', 'NP'),
	(2267, 'NPDH', 'Dhawalagiri', 'NP'),
	(2268, 'NPGA', 'Gandaki', 'NP'),
	(2269, 'NPJA', 'Janakpur', 'NP'),
	(2270, 'NPKA', 'Karnali', 'NP'),
	(2271, 'NPKO', 'Kosi', 'NP'),
	(2272, 'NPLU', 'Lumbini', 'NP'),
	(2273, 'NPMA', 'Mahakali', 'NP'),
	(2274, 'NPME', 'Mechi', 'NP'),
	(2275, 'NPNA', 'Narayani', 'NP'),
	(2276, 'NPRA', 'Rapti', 'NP'),
	(2277, 'NPSA', 'Sagarmatha', 'NP'),
	(2278, 'NPSE', 'Seti', 'NP'),
	(2279, 'NR14', 'Yaren', 'NR'),
	(2280, 'NZAUK', 'Auckland', 'NZ'),
	(2281, 'NZBOP', 'Bay of Plenty', 'NZ'),
	(2282, 'NZCAN', 'Canterbury', 'NZ'),
	(2283, 'NZCIT', 'Chatham Islands Territory', 'NZ'),
	(2284, 'NZGIS', 'Gisborne', 'NZ'),
	(2285, 'NZHKB', 'Hawkes Bay', 'NZ'),
	(2286, 'NZMBH', 'Marlborough', 'NZ'),
	(2287, 'NZMWT', 'Manawatu-Wanganui', 'NZ'),
	(2288, 'NZNSN', 'Nelson', 'NZ'),
	(2289, 'NZNTL', 'Northland', 'NZ'),
	(2290, 'NZOTA', 'Otago', 'NZ'),
	(2291, 'NZSTL', 'Southland', 'NZ'),
	(2292, 'NZTAS', 'Tasman', 'NZ'),
	(2293, 'NZTKI', 'Taranaki', 'NZ'),
	(2294, 'NZWGN', 'Wellington', 'NZ'),
	(2295, 'NZWKO', 'Waikato', 'NZ'),
	(2296, 'NZWTC', 'West Coast', 'NZ'),
	(2297, 'OMBJ', 'Janub al Batinah', 'OM'),
	(2298, 'OMBS', 'Shamal al Batinah', 'OM'),
	(2299, 'OMBU', 'Al Buraymi', 'OM'),
	(2300, 'OMDA', 'Ad Dakhiliyah', 'OM'),
	(2301, 'OMMA', 'Masqat', 'OM'),
	(2302, 'OMMU', 'Musandam', 'OM'),
	(2303, 'OMSJ', 'Janub ash Sharqiyah', 'OM'),
	(2304, 'OMSS', 'Shamal ash Sharqiyah', 'OM'),
	(2305, 'OMWU', 'Al Wusta', 'OM'),
	(2306, 'OMZA', 'Az Zahirah', 'OM'),
	(2307, 'OMZU', 'Zufar', 'OM'),
	(2308, 'PA1', 'Bocas del Toro', 'PA'),
	(2309, 'PA2', 'Cocle', 'PA'),
	(2310, 'PA3', 'Colon', 'PA'),
	(2311, 'PA4', 'Chiriqui', 'PA'),
	(2312, 'PA5', 'Darien', 'PA'),
	(2313, 'PA6', 'Herrera', 'PA'),
	(2314, 'PA7', 'Los Santos', 'PA'),
	(2315, 'PA8', 'Panama', 'PA'),
	(2316, 'PA9', 'Veraguas', 'PA'),
	(2317, 'PEAMA', 'Amazonas', 'PE'),
	(2318, 'PEANC', 'Ancash', 'PE'),
	(2319, 'PEAPU', 'Apurimac', 'PE'),
	(2320, 'PEARE', 'Arequipa', 'PE'),
	(2321, 'PEAYA', 'Ayacucho', 'PE'),
	(2322, 'PECAJ', 'Cajamarca', 'PE'),
	(2323, 'PECAL', 'El Callao', 'PE'),
	(2324, 'PECUS', 'Cusco', 'PE'),
	(2325, 'PEHUC', 'Huanuco', 'PE'),
	(2326, 'PEHUV', 'Huancavelica', 'PE'),
	(2327, 'PEICA', 'Ica', 'PE'),
	(2328, 'PEJUN', 'Junin', 'PE'),
	(2329, 'PELAL', 'La Libertad', 'PE'),
	(2330, 'PELAM', 'Lambayeque', 'PE'),
	(2331, 'PELIM', 'Lima', 'PE'),
	(2332, 'PELOR', 'Loreto', 'PE'),
	(2333, 'PEMDD', 'Madre de Dios', 'PE'),
	(2334, 'PEMOQ', 'Moquegua', 'PE'),
	(2335, 'PEPAS', 'Pasco', 'PE'),
	(2336, 'PEPIU', 'Piura', 'PE'),
	(2337, 'PEPUN', 'Puno', 'PE'),
	(2338, 'PESAM', 'San Martin', 'PE'),
	(2339, 'PETAC', 'Tacna', 'PE'),
	(2340, 'PETUM', 'Tumbes', 'PE'),
	(2341, 'PEUCA', 'Ucayali', 'PE'),
	(2342, NULL, 'Iles Australes', 'PF'),
	(2343, NULL, 'Iles du Vent', 'PF'),
	(2344, NULL, 'Iles Marquises', 'PF'),
	(2345, NULL, 'Iles Sous-le-Vent', 'PF'),
	(2346, NULL, 'Iles Tuamotu-Gambier', 'PF'),
	(2347, 'PGCPK', 'Chimbu', 'PG'),
	(2348, 'PGEBR', 'East New Britain', 'PG'),
	(2349, 'PGEHG', 'Eastern Highlands', 'PG'),
	(2350, 'PGEPW', 'Enga', 'PG'),
	(2351, 'PGESW', 'East Sepik', 'PG'),
	(2352, 'PGGPK', 'Gulf', 'PG'),
	(2353, 'PGMBA', 'Milne Bay', 'PG'),
	(2354, 'PGMPL', 'Morobe', 'PG'),
	(2355, 'PGMPM', 'Madang', 'PG'),
	(2356, 'PGMRL', 'Manus', 'PG'),
	(2357, 'PGNCD', 'National Capital District (Port Moresby)', 'PG'),
	(2358, 'PGNIK', 'New Ireland', 'PG'),
	(2359, 'PGNPP', 'Northern', 'PG'),
	(2360, 'PGNSB', 'Bougainville', 'PG'),
	(2361, 'PGSAN', 'West Sepik', 'PG'),
	(2362, 'PGSHM', 'Southern Highlands', 'PG'),
	(2363, 'PGWBK', 'West New Britain', 'PG'),
	(2364, 'PGWHM', 'Western Highlands', 'PG'),
	(2365, 'PGWPD', 'Western', 'PG'),
	(2366, 'PH00', 'National Capital Region', 'PH'),
	(2367, 'PHABR', 'Abra', 'PH'),
	(2368, 'PHAGN', 'Agusan del Norte', 'PH'),
	(2369, 'PHAGS', 'Agusan del Sur', 'PH'),
	(2370, 'PHAKL', 'Aklan', 'PH'),
	(2371, 'PHALB', 'Albay', 'PH'),
	(2372, 'PHANT', 'Antique', 'PH'),
	(2373, 'PHAPA', 'Apayao', 'PH'),
	(2374, 'PHAUR', 'Aurora', 'PH'),
	(2375, 'PHBAN', 'Bataan', 'PH'),
	(2376, 'PHBAS', 'Basilan', 'PH'),
	(2377, 'PHBEN', 'Benguet', 'PH'),
	(2378, 'PHBOH', 'Bohol', 'PH'),
	(2379, 'PHBTG', 'Batangas', 'PH'),
	(2380, 'PHBTN', 'Batanes', 'PH'),
	(2381, 'PHBUK', 'Bukidnon', 'PH'),
	(2382, 'PHBUL', 'Bulacan', 'PH'),
	(2383, 'PHCAG', 'Cagayan', 'PH'),
	(2384, 'PHCAM', 'Camiguin', 'PH'),
	(2385, 'PHCAN', 'Camarines Norte', 'PH'),
	(2386, 'PHCAP', 'Capiz', 'PH'),
	(2387, 'PHCAS', 'Camarines Sur', 'PH'),
	(2388, 'PHCAT', 'Catanduanes', 'PH'),
	(2389, 'PHCAV', 'Cavite', 'PH'),
	(2390, 'PHCEB', 'Cebu', 'PH'),
	(2391, 'PHDAO', 'Davao Oriental', 'PH'),
	(2392, 'PHDAS', 'Davao del Sur', 'PH'),
	(2393, 'PHEAS', 'Eastern Samar', 'PH'),
	(2394, 'PHIFU', 'Ifugao', 'PH'),
	(2395, 'PHILI', 'Iloilo', 'PH'),
	(2396, 'PHILN', 'Ilocos Norte', 'PH'),
	(2397, 'PHILS', 'Ilocos Sur', 'PH'),
	(2398, 'PHISA', 'Isabela', 'PH'),
	(2399, 'PHKAL', 'Kalinga', 'PH'),
	(2400, 'PHLAG', 'Laguna', 'PH'),
	(2401, 'PHLAN', 'Lanao del Norte', 'PH'),
	(2402, 'PHLAS', 'Lanao del Sur', 'PH'),
	(2403, 'PHLEY', 'Leyte', 'PH'),
	(2404, 'PHLUN', 'La Union', 'PH'),
	(2405, 'PHMAD', 'Marinduque', 'PH'),
	(2406, 'PHMAG', 'Maguindanao', 'PH'),
	(2407, 'PHMAS', 'Masbate', 'PH'),
	(2408, 'PHMDC', 'Mindoro Occidental', 'PH'),
	(2409, 'PHMDR', 'Mindoro Oriental', 'PH'),
	(2410, 'PHMOU', 'Mountain Province', 'PH'),
	(2411, 'PHMSC', 'Misamis Occidental', 'PH'),
	(2412, 'PHMSR', 'Misamis Oriental', 'PH'),
	(2413, 'PHNCO', 'Cotabato', 'PH'),
	(2414, 'PHNEC', 'Negros Occidental', 'PH'),
	(2415, 'PHNER', 'Negros Oriental', 'PH'),
	(2416, 'PHNSA', 'Northern Samar', 'PH'),
	(2417, 'PHNUE', 'Nueva Ecija', 'PH'),
	(2418, 'PHNUV', 'Nueva Vizcaya', 'PH'),
	(2419, 'PHPAM', 'Pampanga', 'PH'),
	(2420, 'PHPAN', 'Pangasinan', 'PH'),
	(2421, 'PHPLW', 'Palawan', 'PH'),
	(2422, 'PHQUE', 'Quezon', 'PH'),
	(2423, 'PHQUI', 'Quirino', 'PH'),
	(2424, 'PHRIZ', 'Rizal', 'PH'),
	(2425, 'PHROM', 'Romblon', 'PH'),
	(2426, 'PHSCO', 'South Cotabato', 'PH'),
	(2427, 'PHSIG', 'Siquijor', 'PH'),
	(2428, 'PHSLE', 'Southern Leyte', 'PH'),
	(2429, 'PHSLU', 'Sulu', 'PH'),
	(2430, 'PHSOR', 'Sorsogon', 'PH'),
	(2431, 'PHSUK', 'Sultan Kudarat', 'PH'),
	(2432, 'PHSUN', 'Surigao del Norte', 'PH'),
	(2433, 'PHSUR', 'Surigao del Sur', 'PH'),
	(2434, 'PHTAR', 'Tarlac', 'PH'),
	(2435, 'PHTAW', 'Tawi-Tawi', 'PH'),
	(2436, 'PHWSA', 'Samar', 'PH'),
	(2437, 'PHZAN', 'Zamboanga del Norte', 'PH'),
	(2438, 'PHZAS', 'Zamboanga del Sur', 'PH'),
	(2439, 'PHZMB', 'Zambales', 'PH'),
	(2440, 'PKBA', 'Balochistan', 'PK'),
	(2441, 'PKGB', 'Gilgit-Baltistan', 'PK'),
	(2442, 'PKIS', 'Islamabad', 'PK'),
	(2443, 'PKJK', 'Azad Kashmir', 'PK'),
	(2444, 'PKKP', 'Khyber Pakhtunkhwa', 'PK'),
	(2445, 'PKPB', 'Punjab', 'PK'),
	(2446, 'PKSD', 'Sindh', 'PK'),
	(2447, 'PKTA', 'Federally Administered Tribal Areas', 'PK'),
	(2448, 'PLDS', 'Dolnoslaskie', 'PL'),
	(2449, 'PLKP', 'Kujawsko-pomorskie', 'PL'),
	(2450, 'PLLB', 'Lubuskie', 'PL'),
	(2451, 'PLLD', 'Lodzkie', 'PL'),
	(2452, 'PLLU', 'Lubelskie', 'PL'),
	(2453, 'PLMA', 'Malopolskie', 'PL'),
	(2454, 'PLMZ', 'Mazowieckie', 'PL'),
	(2455, 'PLOP', 'Opolskie', 'PL'),
	(2456, 'PLPD', 'Podlaskie', 'PL'),
	(2457, 'PLPK', 'Podkarpackie', 'PL'),
	(2458, 'PLPM', 'Pomorskie', 'PL'),
	(2459, 'PLSK', 'Swietokrzyskie', 'PL'),
	(2460, 'PLSL', 'Slaskie', 'PL'),
	(2461, 'PLWN', 'Warminsko-mazurskie', 'PL'),
	(2462, 'PLWP', 'Wielkopolskie', 'PL'),
	(2463, 'PLZP', 'Zachodniopomorskie', 'PL'),
	(2464, NULL, 'Saint Pierre and Miquelon', 'PM'),
	(2465, NULL, 'Pitcairn Islands', 'PN'),
	(2466, NULL, 'Adjuntas', 'PR'),
	(2467, NULL, 'Aguada', 'PR'),
	(2468, NULL, 'Aguadilla', 'PR'),
	(2469, NULL, 'Aguas Buenas', 'PR'),
	(2470, NULL, 'Aibonito', 'PR'),
	(2471, NULL, 'Anasco', 'PR'),
	(2472, NULL, 'Arecibo', 'PR'),
	(2473, NULL, 'Arroyo', 'PR'),
	(2474, NULL, 'Barceloneta', 'PR'),
	(2475, NULL, 'Barranquitas', 'PR'),
	(2476, NULL, 'Bayamon', 'PR'),
	(2477, NULL, 'Cabo Rojo', 'PR'),
	(2478, NULL, 'Caguas', 'PR'),
	(2479, NULL, 'Camuy', 'PR'),
	(2480, NULL, 'Canovanas', 'PR'),
	(2481, NULL, 'Carolina', 'PR'),
	(2482, NULL, 'Catano', 'PR'),
	(2483, NULL, 'Cayey', 'PR'),
	(2484, NULL, 'Ceiba', 'PR'),
	(2485, NULL, 'Ciales', 'PR'),
	(2486, NULL, 'Cidra', 'PR'),
	(2487, NULL, 'Coamo', 'PR'),
	(2488, NULL, 'Comerio', 'PR'),
	(2489, NULL, 'Corozal', 'PR'),
	(2490, NULL, 'Culebra', 'PR'),
	(2491, NULL, 'Dorado', 'PR'),
	(2492, NULL, 'Fajardo', 'PR'),
	(2493, NULL, 'Florida', 'PR'),
	(2494, NULL, 'Guanica', 'PR'),
	(2495, NULL, 'Guayama', 'PR'),
	(2496, NULL, 'Guayanilla', 'PR'),
	(2497, NULL, 'Guaynabo', 'PR'),
	(2498, NULL, 'Gurabo', 'PR'),
	(2499, NULL, 'Hatillo', 'PR'),
	(2500, NULL, 'Hormigueros', 'PR');
INSERT INTO public.sehir VALUES
	(2501, NULL, 'Humacao', 'PR'),
	(2502, NULL, 'Isabela', 'PR'),
	(2503, NULL, 'Juana Diaz', 'PR'),
	(2504, NULL, 'Lajas', 'PR'),
	(2505, NULL, 'Lares', 'PR'),
	(2506, NULL, 'Las Marias', 'PR'),
	(2507, NULL, 'Las Piedras', 'PR'),
	(2508, NULL, 'Loiza', 'PR'),
	(2509, NULL, 'Luquillo', 'PR'),
	(2510, NULL, 'Manati', 'PR'),
	(2511, NULL, 'Maricao', 'PR'),
	(2512, NULL, 'Maunabo', 'PR'),
	(2513, NULL, 'Mayaguez', 'PR'),
	(2514, NULL, 'Moca', 'PR'),
	(2515, NULL, 'Morovis', 'PR'),
	(2516, NULL, 'Municipio de Jayuya', 'PR'),
	(2517, NULL, 'Municipio de Juncos', 'PR'),
	(2518, NULL, 'Naguabo', 'PR'),
	(2519, NULL, 'Naranjito', 'PR'),
	(2520, NULL, 'Patillas', 'PR'),
	(2521, NULL, 'Penuelas', 'PR'),
	(2522, NULL, 'Ponce', 'PR'),
	(2523, NULL, 'Quebradillas', 'PR'),
	(2524, NULL, 'Rincon', 'PR'),
	(2525, NULL, 'Rio Grande', 'PR'),
	(2526, NULL, 'Sabana Grande', 'PR'),
	(2527, NULL, 'Salinas', 'PR'),
	(2528, NULL, 'San German', 'PR'),
	(2529, NULL, 'San Juan', 'PR'),
	(2530, NULL, 'San Lorenzo', 'PR'),
	(2531, NULL, 'San Sebastian', 'PR'),
	(2532, NULL, 'Santa Isabel Municipio', 'PR'),
	(2533, NULL, 'Toa Alta', 'PR'),
	(2534, NULL, 'Toa Baja', 'PR'),
	(2535, NULL, 'Trujillo Alto', 'PR'),
	(2536, NULL, 'Utuado', 'PR'),
	(2537, NULL, 'Vega Alta', 'PR'),
	(2538, NULL, 'Vega Baja', 'PR'),
	(2539, NULL, 'Vieques', 'PR'),
	(2540, NULL, 'Villalba', 'PR'),
	(2541, NULL, 'Yauco', 'PR'),
	(2542, 'PSBTH', 'Bethlehem', 'PS'),
	(2543, 'PSGZA', 'Gaza', 'PS'),
	(2544, 'PSHBN', 'Hebron', 'PS'),
	(2545, 'PSJEM', 'Jerusalem', 'PS'),
	(2546, 'PSJEN', 'Jenin', 'PS'),
	(2547, 'PSJRH', 'Jericho and Al Aghwar', 'PS'),
	(2548, 'PSNBS', 'Nablus', 'PS'),
	(2549, 'PSQQA', 'Qalqilya', 'PS'),
	(2550, 'PSRBH', 'Ramallah', 'PS'),
	(2551, 'PSSLT', 'Salfit', 'PS'),
	(2552, 'PSTBS', 'Tubas', 'PS'),
	(2553, 'PSTKM', 'Tulkarm', 'PS'),
	(2554, 'PT01', 'Aveiro', 'PT'),
	(2555, 'PT02', 'Beja', 'PT'),
	(2556, 'PT03', 'Braga', 'PT'),
	(2557, 'PT04', 'Braganca', 'PT'),
	(2558, 'PT05', 'Castelo Branco', 'PT'),
	(2559, 'PT06', 'Coimbra', 'PT'),
	(2560, 'PT07', 'Evora', 'PT'),
	(2561, 'PT08', 'Faro', 'PT'),
	(2562, 'PT09', 'Guarda', 'PT'),
	(2563, 'PT10', 'Leiria', 'PT'),
	(2564, 'PT11', 'Lisboa', 'PT'),
	(2565, 'PT12', 'Portalegre', 'PT'),
	(2566, 'PT13', 'Porto', 'PT'),
	(2567, 'PT14', 'Santarem', 'PT'),
	(2568, 'PT15', 'Setubal', 'PT'),
	(2569, 'PT16', 'Viana do Castelo', 'PT'),
	(2570, 'PT17', 'Vila Real', 'PT'),
	(2571, 'PT18', 'Viseu', 'PT'),
	(2572, 'PT20', 'Regiao Autonoma dos Acores', 'PT'),
	(2573, 'PT30', 'Regiao Autonoma da Madeira', 'PT'),
	(2574, 'PW002', 'Aimeliik', 'PW'),
	(2575, 'PW004', 'Airai', 'PW'),
	(2576, 'PW010', 'Angaur', 'PW'),
	(2577, 'PW100', 'Kayangel', 'PW'),
	(2578, 'PW150', 'Koror', 'PW'),
	(2579, 'PW212', 'Melekeok', 'PW'),
	(2580, 'PW214', 'Ngaraard', 'PW'),
	(2581, 'PW218', 'Ngarchelong', 'PW'),
	(2582, 'PW222', 'Ngardmau', 'PW'),
	(2583, 'PW224', 'Ngatpang', 'PW'),
	(2584, 'PW228', 'Ngiwal', 'PW'),
	(2585, 'PW350', 'Peleliu', 'PW'),
	(2586, 'PY1', 'Concepcion', 'PY'),
	(2587, 'PY10', 'Alto Parana', 'PY'),
	(2588, 'PY11', 'Central', 'PY'),
	(2589, 'PY12', 'Neembucu', 'PY'),
	(2590, 'PY13', 'Amambay', 'PY'),
	(2591, 'PY14', 'Canindeyu', 'PY'),
	(2592, 'PY15', 'Presidente Hayes', 'PY'),
	(2593, 'PY16', 'Alto Paraguay', 'PY'),
	(2594, 'PY19', 'Boqueron', 'PY'),
	(2595, 'PY2', 'San Pedro', 'PY'),
	(2596, 'PY3', 'Cordillera', 'PY'),
	(2597, 'PY4', 'Guaira', 'PY'),
	(2598, 'PY5', 'Caaguazu', 'PY'),
	(2599, 'PY6', 'Caazapa', 'PY'),
	(2600, 'PY7', 'Itapua', 'PY'),
	(2601, 'PY8', 'Misiones', 'PY'),
	(2602, 'PY9', 'Paraguari', 'PY'),
	(2603, 'PYASU', 'Asuncion', 'PY'),
	(2604, 'QADA', 'Ad Dawhah', 'QA'),
	(2605, 'QAKH', 'Al Khawr wa adh Dhakhirah', 'QA'),
	(2606, 'QAMS', 'Ash Shamal', 'QA'),
	(2607, 'QARA', 'Ar Rayyan', 'QA'),
	(2608, 'QAUS', 'Umm Salal', 'QA'),
	(2609, 'QAWA', 'Al Wakrah', 'QA'),
	(2610, 'QAZA', 'Az Zaayin', 'QA'),
	(2611, NULL, 'Reunion', 'RE'),
	(2612, 'ROAB', 'Alba', 'RO'),
	(2613, 'ROAG', 'Arges', 'RO'),
	(2614, 'ROAR', 'Arad', 'RO'),
	(2615, 'ROB', 'Bucuresti', 'RO'),
	(2616, 'ROBC', 'Bacau', 'RO'),
	(2617, 'ROBH', 'Bihor', 'RO'),
	(2618, 'ROBN', 'Bistrita-Nasaud', 'RO'),
	(2619, 'ROBR', 'Braila', 'RO'),
	(2620, 'ROBT', 'Botosani', 'RO'),
	(2621, 'ROBV', 'Brasov', 'RO'),
	(2622, 'ROBZ', 'Buzau', 'RO'),
	(2623, 'ROCJ', 'Cluj', 'RO'),
	(2624, 'ROCL', 'Calarasi', 'RO'),
	(2625, 'ROCS', 'Caras-Severin', 'RO'),
	(2626, 'ROCT', 'Constanta', 'RO'),
	(2627, 'ROCV', 'Covasna', 'RO'),
	(2628, 'RODB', 'Dambovita', 'RO'),
	(2629, 'RODJ', 'Dolj', 'RO'),
	(2630, 'ROGJ', 'Gorj', 'RO'),
	(2631, 'ROGL', 'Galati', 'RO'),
	(2632, 'ROGR', 'Giurgiu', 'RO'),
	(2633, 'ROHD', 'Hunedoara', 'RO'),
	(2634, 'ROHR', 'Harghita', 'RO'),
	(2635, 'ROIF', 'Ilfov', 'RO'),
	(2636, 'ROIL', 'Ialomita', 'RO'),
	(2637, 'ROIS', 'Iasi', 'RO'),
	(2638, 'ROMH', 'Mehedinti', 'RO'),
	(2639, 'ROMM', 'Maramures', 'RO'),
	(2640, 'ROMS', 'Mures', 'RO'),
	(2641, 'RONT', 'Neamt', 'RO'),
	(2642, 'ROOT', 'Olt', 'RO'),
	(2643, 'ROPH', 'Prahova', 'RO'),
	(2644, 'ROSB', 'Sibiu', 'RO'),
	(2645, 'ROSJ', 'Salaj', 'RO'),
	(2646, 'ROSM', 'Satu Mare', 'RO'),
	(2647, 'ROSV', 'Suceava', 'RO'),
	(2648, 'ROTL', 'Tulcea', 'RO'),
	(2649, 'ROTM', 'Timis', 'RO'),
	(2650, 'ROTR', 'Teleorman', 'RO'),
	(2651, 'ROVL', 'Valcea', 'RO'),
	(2652, 'ROVN', 'Vrancea', 'RO'),
	(2653, 'ROVS', 'Vaslui', 'RO'),
	(2654, 'RS00', 'Beograd', 'RS'),
	(2655, 'RS01', 'Severnobacki okrug', 'RS'),
	(2656, 'RS02', 'Srednjebanatski okrug', 'RS'),
	(2657, 'RS03', 'Severnobanatski okrug', 'RS'),
	(2658, 'RS04', 'Juznobanatski okrug', 'RS'),
	(2659, 'RS05', 'Zapadnobacki okrug', 'RS'),
	(2660, 'RS06', 'Juznobacki okrug', 'RS'),
	(2661, 'RS07', 'Sremski okrug', 'RS'),
	(2662, 'RS08', 'Macvanski okrug', 'RS'),
	(2663, 'RS09', 'Kolubarski okrug', 'RS'),
	(2664, 'RS10', 'Podunavski okrug', 'RS'),
	(2665, 'RS11', 'Branicevski okrug', 'RS'),
	(2666, 'RS12', 'Sumadijski okrug', 'RS'),
	(2667, 'RS14', 'Borski okrug', 'RS'),
	(2668, 'RS15', 'Zajecarski okrug', 'RS'),
	(2669, 'RS16', 'Zlatiborski okrug', 'RS'),
	(2670, 'RS17', 'Moravicki okrug', 'RS'),
	(2671, 'RS18', 'Raski okrug', 'RS'),
	(2672, 'RS19', 'Rasinski okrug', 'RS'),
	(2673, 'RS20', 'Nisavski okrug', 'RS'),
	(2674, 'RS21', 'Toplicki okrug', 'RS'),
	(2675, 'RS22', 'Pirotski okrug', 'RS'),
	(2676, 'RS23', 'Jablanicki okrug', 'RS'),
	(2677, 'RS24', 'Pcinjski okrug', 'RS'),
	(2678, 'RS26', 'Pecki okrug', 'RS'),
	(2679, 'RS27', 'Prizrenski okrug', 'RS'),
	(2680, 'RS28', 'Kosovsko-Mitrovacki okrug', 'RS'),
	(2681, 'RUAD', 'Adygeya, Respublika', 'RU'),
	(2682, 'RUAL', 'Altay, Respublika', 'RU'),
	(2683, 'RUALT', 'Altayskiy kray', 'RU'),
	(2684, 'RUAMU', 'Amurskaya oblast', 'RU'),
	(2685, 'RUARK', 'Arkhangelskaya oblast', 'RU'),
	(2686, 'RUAST', 'Astrakhanskaya oblast', 'RU'),
	(2687, 'RUBA', 'Bashkortostan, Respublika', 'RU'),
	(2688, 'RUBEL', 'Belgorodskaya oblast', 'RU'),
	(2689, 'RUBRY', 'Bryanskaya oblast', 'RU'),
	(2690, 'RUBU', 'Buryatiya, Respublika', 'RU'),
	(2691, 'RUCE', 'Chechenskaya Respublika', 'RU'),
	(2692, 'RUCHE', 'Chelyabinskaya oblast', 'RU'),
	(2693, 'RUCHU', 'Chukotskiy avtonomnyy okrug', 'RU'),
	(2694, 'RUCU', 'Chuvashskaya Respublika', 'RU'),
	(2695, 'RUDA', 'Dagestan, Respublika', 'RU'),
	(2696, 'RUIN', 'Ingushetiya, Respublika', 'RU'),
	(2697, 'RUIRK', 'Irkutskaya oblast', 'RU'),
	(2698, 'RUIVA', 'Ivanovskaya oblast', 'RU'),
	(2699, 'RUKAM', 'Kamchatskiy kray', 'RU'),
	(2700, 'RUKB', 'Kabardino-Balkarskaya Respublika', 'RU'),
	(2701, 'RUKC', 'Karachayevo-Cherkesskaya Respublika', 'RU'),
	(2702, 'RUKDA', 'Krasnodarskiy kray', 'RU'),
	(2703, 'RUKEM', 'Kemerovskaya oblast', 'RU'),
	(2704, 'RUKGD', 'Kaliningradskaya oblast', 'RU'),
	(2705, 'RUKGN', 'Kurganskaya oblast', 'RU'),
	(2706, 'RUKHA', 'Khabarovskiy kray', 'RU'),
	(2707, 'RUKHM', 'Khanty-Mansiyskiy avtonomnyy okrug', 'RU'),
	(2708, 'RUKIR', 'Kirovskaya oblast', 'RU'),
	(2709, 'RUKK', 'Khakasiya, Respublika', 'RU'),
	(2710, 'RUKL', 'Kalmykiya, Respublika', 'RU'),
	(2711, 'RUKLU', 'Kaluzhskaya oblast', 'RU'),
	(2712, 'RUKO', 'Komi, Respublika', 'RU'),
	(2713, 'RUKOS', 'Kostromskaya oblast', 'RU'),
	(2714, 'RUKR', 'Kareliya, Respublika', 'RU'),
	(2715, 'RUKRS', 'Kurskaya oblast', 'RU'),
	(2716, 'RUKYA', 'Krasnoyarskiy kray', 'RU'),
	(2717, 'RULEN', 'Leningradskaya oblast', 'RU'),
	(2718, 'RULIP', 'Lipetskaya oblast', 'RU'),
	(2719, 'RUMAG', 'Magadanskaya oblast', 'RU'),
	(2720, 'RUME', 'Mariy El, Respublika', 'RU'),
	(2721, 'RUMO', 'Mordoviya, Respublika', 'RU'),
	(2722, 'RUMOS', 'Moskovskaya oblast', 'RU'),
	(2723, 'RUMOW', 'Moskva', 'RU'),
	(2724, 'RUMUR', 'Murmanskaya oblast', 'RU'),
	(2725, 'RUNEN', 'Nenetskiy avtonomnyy okrug', 'RU'),
	(2726, 'RUNGR', 'Novgorodskaya oblast', 'RU'),
	(2727, 'RUNIZ', 'Nizhegorodskaya oblast', 'RU'),
	(2728, 'RUNVS', 'Novosibirskaya oblast', 'RU'),
	(2729, 'RUOMS', 'Omskaya oblast', 'RU'),
	(2730, 'RUORE', 'Orenburgskaya oblast', 'RU'),
	(2731, 'RUORL', 'Orlovskaya oblast', 'RU'),
	(2732, 'RUPER', 'Permskiy kray', 'RU'),
	(2733, 'RUPNZ', 'Penzenskaya oblast', 'RU'),
	(2734, 'RUPRI', 'Primorskiy kray', 'RU'),
	(2735, 'RUPSK', 'Pskovskaya oblast', 'RU'),
	(2736, 'RUROS', 'Rostovskaya oblast', 'RU'),
	(2737, 'RURYA', 'Ryazanskaya oblast', 'RU'),
	(2738, 'RUSA', 'Saha, Respublika', 'RU'),
	(2739, 'RUSAK', 'Sakhalinskaya oblast', 'RU'),
	(2740, 'RUSAM', 'Samarskaya oblast', 'RU'),
	(2867, 'SI061', 'Ljubljana', 'SI'),
	(2741, 'RUSAR', 'Saratovskaya oblast', 'RU'),
	(2742, 'RUSE', 'Severnaya Osetiya, Respublika', 'RU'),
	(2743, 'RUSMO', 'Smolenskaya oblast', 'RU'),
	(2744, 'RUSPE', 'Sankt-Peterburg', 'RU'),
	(2745, 'RUSTA', 'Stavropolskiy kray', 'RU'),
	(2746, 'RUSVE', 'Sverdlovskaya oblast', 'RU'),
	(2747, 'RUTA', 'Tatarstan, Respublika', 'RU'),
	(2748, 'RUTAM', 'Tambovskaya oblast', 'RU'),
	(2749, 'RUTOM', 'Tomskaya oblast', 'RU');
INSERT INTO public.sehir VALUES
	(2750, 'RUTUL', 'Tulskaya oblast', 'RU'),
	(2751, 'RUTVE', 'Tverskaya oblast', 'RU'),
	(2752, 'RUTY', 'Tyva, Respublika', 'RU'),
	(2753, 'RUTYU', 'Tyumenskaya oblast', 'RU'),
	(2754, 'RUUD', 'Udmurtskaya Respublika', 'RU'),
	(2755, 'RUULY', 'Ulyanovskaya oblast', 'RU'),
	(2756, 'RUVGG', 'Volgogradskaya oblast', 'RU'),
	(2757, 'RUVLA', 'Vladimirskaya oblast', 'RU'),
	(2758, 'RUVLG', 'Vologodskaya oblast', 'RU'),
	(2759, 'RUVOR', 'Voronezhskaya oblast', 'RU'),
	(2760, 'RUYAN', 'Yamalo-Nenetskiy avtonomnyy okrug', 'RU'),
	(2761, 'RUYAR', 'Yaroslavskaya oblast', 'RU'),
	(2762, 'RUYEV', 'Yevreyskaya avtonomnaya oblast', 'RU'),
	(2763, 'RUZAB', 'Zabaykalskiy kray', 'RU'),
	(2764, 'RW01', 'Ville de Kigali', 'RW'),
	(2765, 'RW02', 'Est', 'RW'),
	(2766, 'RW03', 'Nord', 'RW'),
	(2767, 'RW04', 'Ouest', 'RW'),
	(2768, 'RW05', 'Sud', 'RW'),
	(2769, 'SA01', 'Ar Riyad', 'SA'),
	(2770, 'SA02', 'Makkah al Mukarramah', 'SA'),
	(2771, 'SA03', 'Al Madinah al Munawwarah', 'SA'),
	(2772, 'SA04', 'Ash Sharqiyah', 'SA'),
	(2773, 'SA05', 'Al Qasim', 'SA'),
	(2774, 'SA06', 'Hail', 'SA'),
	(2775, 'SA07', 'Tabuk', 'SA'),
	(2776, 'SA08', 'Al Hudud ash Shamaliyah', 'SA'),
	(2777, 'SA09', 'Jazan', 'SA'),
	(2778, 'SA10', 'Najran', 'SA'),
	(2779, 'SA11', 'Al Bahah', 'SA'),
	(2780, 'SA12', 'Al Jawf', 'SA'),
	(2781, 'SA14', 'Asir', 'SA'),
	(2782, 'SBCE', 'Central', 'SB'),
	(2783, 'SBGU', 'Guadalcanal', 'SB'),
	(2784, 'SBIS', 'Isabel', 'SB'),
	(2785, 'SBMK', 'Makira-Ulawa', 'SB'),
	(2786, 'SBML', 'Malaita', 'SB'),
	(2787, 'SBWE', 'Western', 'SB'),
	(2788, 'SC16', 'English River', 'SC'),
	(2789, 'SDDN', 'North Darfur', 'SD'),
	(2790, 'SDDS', 'South Darfur', 'SD'),
	(2791, 'SDDW', 'West Darfur', 'SD'),
	(2792, 'SDGD', 'Gedaref', 'SD'),
	(2793, 'SDGZ', 'Gezira', 'SD'),
	(2794, 'SDKA', 'Kassala', 'SD'),
	(2795, 'SDKH', 'Khartoum', 'SD'),
	(2796, 'SDKN', 'North Kordofan', 'SD'),
	(2797, 'SDKS', 'South Kordofan', 'SD'),
	(2798, 'SDNB', 'Blue Nile', 'SD'),
	(2799, 'SDNO', 'Northern', 'SD'),
	(2800, 'SDNR', 'River Nile', 'SD'),
	(2801, 'SDNW', 'White Nile', 'SD'),
	(2802, 'SDRS', 'Red Sea', 'SD'),
	(2803, 'SDSI', 'Sennar', 'SD'),
	(2804, 'SEAB', 'Stockholms lan', 'SE'),
	(2805, 'SEAC', 'Vasterbottens lan', 'SE'),
	(2806, 'SEBD', 'Norrbottens lan', 'SE'),
	(2807, 'SEC', 'Uppsala lan', 'SE'),
	(2808, 'SED', 'Sodermanlands lan', 'SE'),
	(2809, 'SEE', 'Ostergotlands lan', 'SE'),
	(2810, 'SEF', 'Jonkopings lan', 'SE'),
	(2811, 'SEG', 'Kronobergs lan', 'SE'),
	(2812, 'SEH', 'Kalmar lan', 'SE'),
	(2813, 'SEI', 'Gotlands lan', 'SE'),
	(2814, 'SEK', 'Blekinge lan', 'SE'),
	(2815, 'SEM', 'Skane lan', 'SE'),
	(2816, 'SEN', 'Hallands lan', 'SE'),
	(2817, 'SEO', 'Vastra Gotalands lan', 'SE'),
	(2818, 'SES', 'Varmlands lan', 'SE'),
	(2819, 'SET', 'Orebro lan', 'SE'),
	(2820, 'SEU', 'Vastmanlands lan', 'SE'),
	(2821, 'SEW', 'Dalarnas lan', 'SE'),
	(2822, 'SEX', 'Gavleborgs lan', 'SE'),
	(2823, 'SEY', 'Vasternorrlands lan', 'SE'),
	(2824, 'SEZ', 'Jamtlands lan', 'SE'),
	(2825, NULL, 'Singapore', 'SG'),
	(2826, 'SHAC', 'Ascension', 'SH'),
	(2827, 'SHHL', 'Saint Helena', 'SH'),
	(2828, 'SHTA', 'Tristan da Cunha', 'SH'),
	(2829, 'SI001', 'Ajdovscina', 'SI'),
	(2830, 'SI003', 'Bled', 'SI'),
	(2831, 'SI004', 'Bohinj', 'SI'),
	(2832, 'SI005', 'Borovnica', 'SI'),
	(2833, 'SI006', 'Bovec', 'SI'),
	(2834, 'SI008', 'Brezovica', 'SI'),
	(2835, 'SI009', 'Brezice', 'SI'),
	(2836, 'SI011', 'Celje', 'SI'),
	(2837, 'SI013', 'Cerknica', 'SI'),
	(2838, 'SI014', 'Cerkno', 'SI'),
	(2839, 'SI015', 'Crensovci', 'SI'),
	(2840, 'SI017', 'Crnomelj', 'SI'),
	(2841, 'SI018', 'Destrnik', 'SI'),
	(2842, 'SI019', 'Divaca', 'SI'),
	(2843, 'SI023', 'Domzale', 'SI'),
	(2844, 'SI025', 'Dravograd', 'SI'),
	(2845, 'SI029', 'Gornja Radgona', 'SI'),
	(2846, 'SI032', 'Grosuplje', 'SI'),
	(2847, 'SI034', 'Hrastnik', 'SI'),
	(2848, 'SI036', 'Idrija', 'SI'),
	(2849, 'SI037', 'Ig', 'SI'),
	(2850, 'SI038', 'Ilirska Bistrica', 'SI'),
	(2851, 'SI039', 'Ivancna Gorica', 'SI'),
	(2852, 'SI040', 'Izola', 'SI'),
	(2853, 'SI041', 'Jesenice', 'SI'),
	(2854, 'SI043', 'Kamnik', 'SI'),
	(2855, 'SI044', 'Kanal', 'SI'),
	(2856, 'SI045', 'Kidricevo', 'SI'),
	(2857, 'SI046', 'Kobarid', 'SI'),
	(2858, 'SI048', 'Kocevje', 'SI'),
	(2859, 'SI050', 'Koper', 'SI'),
	(2860, 'SI052', 'Kranj', 'SI'),
	(2861, 'SI053', 'Kranjska Gora', 'SI'),
	(2862, 'SI054', 'Krsko', 'SI'),
	(2863, 'SI057', 'Lasko', 'SI'),
	(2864, 'SI058', 'Lenart', 'SI'),
	(2865, 'SI059', 'Lendava', 'SI'),
	(2866, 'SI060', 'Litija', 'SI'),
	(2868, 'SI063', 'Ljutomer', 'SI'),
	(2869, 'SI064', 'Logatec', 'SI'),
	(2870, 'SI070', 'Maribor', 'SI'),
	(2871, 'SI071', 'Medvode', 'SI'),
	(2872, 'SI072', 'Menges', 'SI'),
	(2873, 'SI073', 'Metlika', 'SI'),
	(2874, 'SI074', 'Mezica', 'SI'),
	(2875, 'SI075', 'Miren-Kostanjevica', 'SI'),
	(2876, 'SI076', 'Mislinja', 'SI'),
	(2877, 'SI079', 'Mozirje', 'SI'),
	(2878, 'SI080', 'Murska Sobota', 'SI'),
	(2879, 'SI081', 'Muta', 'SI'),
	(2880, 'SI084', 'Nova Gorica', 'SI'),
	(2881, 'SI085', 'Novo Mesto', 'SI'),
	(2882, 'SI086', 'Odranci', 'SI'),
	(2883, 'SI087', 'Ormoz', 'SI'),
	(2884, 'SI090', 'Piran', 'SI'),
	(2885, 'SI091', 'Pivka', 'SI'),
	(2886, 'SI094', 'Postojna', 'SI'),
	(2887, 'SI096', 'Ptuj', 'SI'),
	(2888, 'SI098', 'Race-Fram', 'SI'),
	(2889, 'SI099', 'Radece', 'SI'),
	(2890, 'SI100', 'Radenci', 'SI'),
	(2891, 'SI101', 'Radlje ob Dravi', 'SI'),
	(2892, 'SI102', 'Radovljica', 'SI'),
	(2893, 'SI103', 'Ravne na Koroskem', 'SI'),
	(2894, 'SI104', 'Ribnica', 'SI'),
	(2895, 'SI106', 'Rogaska Slatina', 'SI'),
	(2896, 'SI108', 'Ruse', 'SI'),
	(2897, 'SI110', 'Sevnica', 'SI'),
	(2898, 'SI111', 'Sezana', 'SI'),
	(2899, 'SI112', 'Slovenj Gradec', 'SI'),
	(2900, 'SI113', 'Slovenska Bistrica', 'SI'),
	(2901, 'SI114', 'Slovenske Konjice', 'SI'),
	(2902, 'SI117', 'Sencur', 'SI'),
	(2903, 'SI118', 'Sentilj', 'SI'),
	(2904, 'SI120', 'Sentjur', 'SI'),
	(2905, 'SI122', 'Skofja Loka', 'SI'),
	(2906, 'SI123', 'Skofljica', 'SI'),
	(2907, 'SI126', 'Sostanj', 'SI'),
	(2908, 'SI127', 'Store', 'SI'),
	(2909, 'SI128', 'Tolmin', 'SI'),
	(2910, 'SI129', 'Trbovlje', 'SI'),
	(2911, 'SI130', 'Trebnje', 'SI'),
	(2912, 'SI131', 'Trzic', 'SI'),
	(2913, 'SI132', 'Turnisce', 'SI'),
	(2914, 'SI133', 'Velenje', 'SI'),
	(2915, 'SI136', 'Vipava', 'SI'),
	(2916, 'SI138', 'Vodice', 'SI'),
	(2917, 'SI139', 'Vojnik', 'SI'),
	(2918, 'SI140', 'Vrhnika', 'SI'),
	(2919, 'SI141', 'Vuzenica', 'SI'),
	(2920, 'SI142', 'Zagorje ob Savi', 'SI'),
	(2921, 'SI144', 'Zrece', 'SI'),
	(2922, 'SI146', 'Zelezniki', 'SI'),
	(2923, 'SI147', 'Ziri', 'SI'),
	(2924, 'SI160', 'Hoce-Slivnica', 'SI'),
	(2925, 'SI162', 'Horjul', 'SI'),
	(2926, 'SI167', 'Lovrenc na Pohorju', 'SI'),
	(2927, 'SI169', 'Miklavz na Dravskem Polju', 'SI'),
	(2928, 'SI171', 'Oplotnica', 'SI'),
	(2929, 'SI173', 'Polzela', 'SI'),
	(2930, 'SI174', 'Prebold', 'SI'),
	(2931, 'SI175', 'Prevalje', 'SI'),
	(2932, 'SI183', 'Sempeter-Vrtojba', 'SI'),
	(2933, 'SI186', 'Trzin', 'SI'),
	(2934, 'SI190', 'Zalec', 'SI'),
	(2935, 'SI193', 'Zuzemberk', 'SI'),
	(2936, 'SI200', 'Poljcane', 'SI'),
	(2937, 'SI203', 'Straza', 'SI'),
	(2938, 'SI208', 'Log-Dragomer', 'SI'),
	(2939, NULL, 'Svalbard and Jan Mayen', 'SJ'),
	(2940, 'SKBC', 'Banskobystricky kraj', 'SK'),
	(2941, 'SKBL', 'Bratislavsky kraj', 'SK'),
	(2942, 'SKKI', 'Kosicky kraj', 'SK'),
	(2943, 'SKNI', 'Nitriansky kraj', 'SK'),
	(2944, 'SKPV', 'Presovsky kraj', 'SK'),
	(2945, 'SKTA', 'Trnavsky kraj', 'SK'),
	(2946, 'SKTC', 'Trenciansky kraj', 'SK'),
	(2947, 'SKZI', 'Zilinsky kraj', 'SK'),
	(2948, 'SLE', 'Eastern', 'SL'),
	(2949, 'SLN', 'Northern', 'SL'),
	(2950, 'SLS', 'Southern', 'SL'),
	(2951, 'SLW', 'Western Area', 'SL'),
	(2952, 'SM01', 'Acquaviva', 'SM'),
	(2953, 'SM02', 'Chiesanuova', 'SM'),
	(2954, 'SM07', 'San Marino', 'SM'),
	(2955, 'SM09', 'Serravalle', 'SM'),
	(2956, 'SNDB', 'Diourbel', 'SN'),
	(2957, 'SNDK', 'Dakar', 'SN'),
	(2958, 'SNFK', 'Fatick', 'SN'),
	(2959, 'SNKA', 'Kaffrine', 'SN'),
	(2960, 'SNKD', 'Kolda', 'SN'),
	(2961, 'SNKE', 'Kedougou', 'SN'),
	(2962, 'SNKL', 'Kaolack', 'SN'),
	(2963, 'SNLG', 'Louga', 'SN'),
	(2964, 'SNMT', 'Matam', 'SN'),
	(2965, 'SNSE', 'Sedhiou', 'SN'),
	(2966, 'SNSL', 'Saint-Louis', 'SN'),
	(2967, 'SNTC', 'Tambacounda', 'SN'),
	(2968, 'SNTH', 'Thies', 'SN'),
	(2969, 'SNZG', 'Ziguinchor', 'SN'),
	(2970, 'SOAW', 'Awdal', 'SO'),
	(2971, 'SOBK', 'Bakool', 'SO'),
	(2972, 'SOBN', 'Banaadir', 'SO'),
	(2973, 'SOBR', 'Bari', 'SO'),
	(2974, 'SOBY', 'Bay', 'SO'),
	(2975, 'SOGA', 'Galguduud', 'SO'),
	(2976, 'SOGE', 'Gedo', 'SO'),
	(2977, 'SOHI', 'Hiiraan', 'SO'),
	(2978, 'SOJD', 'Jubbada Dhexe', 'SO'),
	(2979, 'SOJH', 'Jubbada Hoose', 'SO'),
	(2980, 'SOMU', 'Mudug', 'SO'),
	(2981, 'SONU', 'Nugaal', 'SO'),
	(2982, 'SOSA', 'Sanaag', 'SO'),
	(2983, 'SOSD', 'Shabeellaha Dhexe', 'SO'),
	(2984, 'SOSH', 'Shabeellaha Hoose', 'SO'),
	(2985, 'SOSO', 'Sool', 'SO'),
	(2986, 'SOTO', 'Togdheer', 'SO'),
	(2987, 'SOWO', 'Woqooyi Galbeed', 'SO'),
	(2988, 'SRBR', 'Brokopondo', 'SR'),
	(2989, 'SRCM', 'Commewijne', 'SR'),
	(2990, 'SRCR', 'Coronie', 'SR'),
	(2991, 'SRMA', 'Marowijne', 'SR'),
	(2992, 'SRNI', 'Nickerie', 'SR'),
	(2993, 'SRPM', 'Paramaribo', 'SR'),
	(2994, 'SRPR', 'Para', 'SR'),
	(2995, 'SRSA', 'Saramacca', 'SR'),
	(2996, 'SRWA', 'Wanica', 'SR'),
	(2997, 'SSBN', 'Northern Bahr el Ghazal', 'SS'),
	(2998, 'SSBW', 'Western Bahr el Ghazal', 'SS'),
	(2999, 'SSEC', 'Central Equatoria', 'SS'),
	(3000, 'SSEE', 'Eastern Equatoria', 'SS');
INSERT INTO public.sehir VALUES
	(3001, 'SSEW', 'Western Equatoria', 'SS'),
	(3002, 'SSJG', 'Jonglei', 'SS'),
	(3003, 'SSLK', 'Lakes', 'SS'),
	(3004, 'SSNU', 'Upper Nile', 'SS'),
	(3005, 'SSUY', 'Unity', 'SS'),
	(3006, 'SSWR', 'Warrap', 'SS'),
	(3007, 'STP', 'Principe', 'ST'),
	(3008, 'STS', 'Sao Tome', 'ST'),
	(3009, 'SVAH', 'Ahuachapan', 'SV'),
	(3010, 'SVCA', 'Cabanas', 'SV'),
	(3011, 'SVCH', 'Chalatenango', 'SV'),
	(3012, 'SVCU', 'Cuscatlan', 'SV'),
	(3013, 'SVLI', 'La Libertad', 'SV'),
	(3014, 'SVMO', 'Morazan', 'SV'),
	(3015, 'SVPA', 'La Paz', 'SV'),
	(3016, 'SVSA', 'Santa Ana', 'SV'),
	(3017, 'SVSM', 'San Miguel', 'SV'),
	(3018, 'SVSO', 'Sonsonate', 'SV'),
	(3019, 'SVSS', 'San Salvador', 'SV'),
	(3020, 'SVSV', 'San Vicente', 'SV'),
	(3021, 'SVUN', 'La Union', 'SV'),
	(3022, 'SVUS', 'Usulutan', 'SV'),
	(3023, NULL, 'Sint Maarten', 'SX'),
	(3024, 'SYDI', 'Dimashq', 'SY'),
	(3025, 'SYDR', 'Dara', 'SY'),
	(3026, 'SYDY', 'Dayr az Zawr', 'SY'),
	(3027, 'SYHA', 'Al Hasakah', 'SY'),
	(3028, 'SYHI', 'Hims', 'SY'),
	(3029, 'SYHL', 'Halab', 'SY'),
	(3030, 'SYHM', 'Hamah', 'SY'),
	(3031, 'SYID', 'Idlib', 'SY'),
	(3032, 'SYLA', 'Al Ladhiqiyah', 'SY'),
	(3033, 'SYQU', 'Al Qunaytirah', 'SY'),
	(3034, 'SYRA', 'Ar Raqqah', 'SY'),
	(3035, 'SYRD', 'Rif Dimashq', 'SY'),
	(3036, 'SYSU', 'As Suwayda', 'SY'),
	(3037, 'SYTA', 'Tartus', 'SY'),
	(3038, 'SZHH', 'Hhohho', 'SZ'),
	(3039, 'SZLU', 'Lubombo', 'SZ'),
	(3040, 'SZMA', 'Manzini', 'SZ'),
	(3041, 'SZSH', 'Shiselweni', 'SZ'),
	(3042, NULL, 'Turks and Caicos Islands', 'TC'),
	(3043, 'TDBA', 'Batha', 'TD'),
	(3044, 'TDBG', 'Bahr el Gazel', 'TD'),
	(3045, 'TDBO', 'Borkou', 'TD'),
	(3046, 'TDCB', 'Chari-Baguirmi', 'TD'),
	(3047, 'TDGR', 'Guera', 'TD'),
	(3048, 'TDHL', 'Hadjer Lamis', 'TD'),
	(3049, 'TDKA', 'Kanem', 'TD'),
	(3050, 'TDLC', 'Lac', 'TD'),
	(3051, 'TDLO', 'Logone-Occidental', 'TD'),
	(3052, 'TDLR', 'Logone-Oriental', 'TD'),
	(3053, 'TDMA', 'Mandoul', 'TD'),
	(3054, 'TDMC', 'Moyen-Chari', 'TD'),
	(3055, 'TDME', 'Mayo-Kebbi-Est', 'TD'),
	(3056, 'TDMO', 'Mayo-Kebbi-Ouest', 'TD'),
	(3057, 'TDOD', 'Ouaddai', 'TD'),
	(3058, 'TDSA', 'Salamat', 'TD'),
	(3059, 'TDTA', 'Tandjile', 'TD'),
	(3060, 'TDTI', 'Tibesti', 'TD'),
	(3061, 'TDWF', 'Wadi Fira', 'TD'),
	(3062, NULL, 'French Southern and Antarctic Lands', 'TF'),
	(3063, 'TGC', 'Centrale', 'TG'),
	(3064, 'TGK', 'Kara', 'TG'),
	(3065, 'TGM', 'Maritime', 'TG'),
	(3066, 'TGP', 'Plateaux', 'TG'),
	(3067, 'TGS', 'Savannes', 'TG'),
	(3068, 'TH10', 'Krung Thep Maha Nakhon', 'TH'),
	(3069, 'TH11', 'Samut Prakan', 'TH'),
	(3070, 'TH12', 'Nonthaburi', 'TH'),
	(3071, 'TH13', 'Pathum Thani', 'TH'),
	(3072, 'TH14', 'Phra Nakhon Si Ayutthaya', 'TH'),
	(3073, 'TH15', 'Ang Thong', 'TH'),
	(3074, 'TH16', 'Lop Buri', 'TH'),
	(3075, 'TH17', 'Sing Buri', 'TH'),
	(3076, 'TH18', 'Chai Nat', 'TH'),
	(3077, 'TH19', 'Saraburi', 'TH'),
	(3078, 'TH20', 'Chon Buri', 'TH'),
	(3079, 'TH21', 'Rayong', 'TH'),
	(3080, 'TH22', 'Chanthaburi', 'TH'),
	(3081, 'TH23', 'Trat', 'TH'),
	(3082, 'TH24', 'Chachoengsao', 'TH'),
	(3083, 'TH25', 'Prachin Buri', 'TH'),
	(3084, 'TH26', 'Nakhon Nayok', 'TH'),
	(3085, 'TH27', 'Sa Kaeo', 'TH'),
	(3086, 'TH30', 'Nakhon Ratchasima', 'TH'),
	(3087, 'TH31', 'Buri Ram', 'TH'),
	(3088, 'TH32', 'Surin', 'TH'),
	(3089, 'TH33', 'Si Sa Ket', 'TH'),
	(3090, 'TH34', 'Ubon Ratchathani', 'TH'),
	(3091, 'TH35', 'Yasothon', 'TH'),
	(3092, 'TH36', 'Chaiyaphum', 'TH'),
	(3093, 'TH37', 'Amnat Charoen', 'TH'),
	(3094, 'TH39', 'Nong Bua Lam Phu', 'TH'),
	(3095, 'TH40', 'Khon Kaen', 'TH'),
	(3096, 'TH41', 'Udon Thani', 'TH'),
	(3097, 'TH42', 'Loei', 'TH'),
	(3098, 'TH43', 'Nong Khai', 'TH'),
	(3099, 'TH44', 'Maha Sarakham', 'TH'),
	(3100, 'TH45', 'Roi Et', 'TH'),
	(3101, 'TH46', 'Kalasin', 'TH'),
	(3102, 'TH47', 'Sakon Nakhon', 'TH'),
	(3103, 'TH48', 'Nakhon Phanom', 'TH'),
	(3104, 'TH49', 'Mukdahan', 'TH'),
	(3105, 'TH50', 'Chiang Mai', 'TH'),
	(3106, 'TH51', 'Lamphun', 'TH'),
	(3107, 'TH52', 'Lampang', 'TH'),
	(3108, 'TH53', 'Uttaradit', 'TH'),
	(3109, 'TH54', 'Phrae', 'TH'),
	(3110, 'TH55', 'Nan', 'TH'),
	(3111, 'TH56', 'Phayao', 'TH'),
	(3112, 'TH57', 'Chiang Rai', 'TH'),
	(3113, 'TH58', 'Mae Hong Son', 'TH'),
	(3114, 'TH60', 'Nakhon Sawan', 'TH'),
	(3115, 'TH61', 'Uthai Thani', 'TH'),
	(3116, 'TH62', 'Kamphaeng Phet', 'TH'),
	(3117, 'TH63', 'Tak', 'TH'),
	(3118, 'TH64', 'Sukhothai', 'TH'),
	(3119, 'TH65', 'Phitsanulok', 'TH'),
	(3120, 'TH66', 'Phichit', 'TH'),
	(3121, 'TH67', 'Phetchabun', 'TH'),
	(3122, 'TH70', 'Ratchaburi', 'TH'),
	(3123, 'TH71', 'Kanchanaburi', 'TH'),
	(3124, 'TH72', 'Suphan Buri', 'TH'),
	(3125, 'TH73', 'Nakhon Pathom', 'TH'),
	(3126, 'TH74', 'Samut Sakhon', 'TH'),
	(3127, 'TH75', 'Samut Songkhram', 'TH'),
	(3128, 'TH76', 'Phetchaburi', 'TH'),
	(3129, 'TH77', 'Prachuap Khiri Khan', 'TH'),
	(3130, 'TH80', 'Nakhon Si Thammarat', 'TH'),
	(3131, 'TH81', 'Krabi', 'TH'),
	(3132, 'TH82', 'Phangnga', 'TH'),
	(3133, 'TH83', 'Phuket', 'TH'),
	(3134, 'TH84', 'Surat Thani', 'TH'),
	(3135, 'TH85', 'Ranong', 'TH'),
	(3136, 'TH86', 'Chumphon', 'TH'),
	(3137, 'TH90', 'Songkhla', 'TH'),
	(3138, 'TH91', 'Satun', 'TH'),
	(3139, 'TH92', 'Trang', 'TH'),
	(3140, 'TH93', 'Phatthalung', 'TH'),
	(3141, 'TH94', 'Pattani', 'TH'),
	(3142, 'TH95', 'Yala', 'TH'),
	(3143, 'TH96', 'Narathiwat', 'TH'),
	(3144, 'TJDU', 'Dushanbe', 'TJ'),
	(3145, 'TJGB', 'Kuhistoni Badakhshon', 'TJ'),
	(3146, 'TJKT', 'Khatlon', 'TJ'),
	(3147, 'TJRA', 'Nohiyahoi Tobei Jumhuri', 'TJ'),
	(3148, 'TJSU', 'Sughd', 'TJ'),
	(3149, NULL, 'Tokelau', 'TK'),
	(3150, 'TLDI', 'Dili', 'TL'),
	(3151, 'TMA', 'Ahal', 'TM'),
	(3152, 'TMB', 'Balkan', 'TM'),
	(3153, 'TMD', 'Dasoguz', 'TM'),
	(3154, 'TML', 'Lebap', 'TM'),
	(3155, 'TMM', 'Mary', 'TM'),
	(3156, 'TN11', 'Tunis', 'TN'),
	(3157, 'TN12', 'LAriana', 'TN'),
	(3158, 'TN13', 'Ben Arous', 'TN'),
	(3159, 'TN14', 'La Manouba', 'TN'),
	(3160, 'TN21', 'Nabeul', 'TN'),
	(3161, 'TN22', 'Zaghouan', 'TN'),
	(3162, 'TN23', 'Bizerte', 'TN'),
	(3163, 'TN31', 'Beja', 'TN'),
	(3164, 'TN32', 'Jendouba', 'TN'),
	(3165, 'TN33', 'Le Kef', 'TN'),
	(3166, 'TN34', 'Siliana', 'TN'),
	(3167, 'TN41', 'Kairouan', 'TN'),
	(3168, 'TN42', 'Kasserine', 'TN'),
	(3169, 'TN43', 'Sidi Bouzid', 'TN'),
	(3170, 'TN51', 'Sousse', 'TN'),
	(3171, 'TN52', 'Monastir', 'TN'),
	(3172, 'TN53', 'Mahdia', 'TN'),
	(3173, 'TN61', 'Sfax', 'TN'),
	(3174, 'TN71', 'Gafsa', 'TN'),
	(3175, 'TN72', 'Tozeur', 'TN'),
	(3176, 'TN73', 'Kebili', 'TN'),
	(3177, 'TN81', 'Gabes', 'TN'),
	(3178, 'TN82', 'Medenine', 'TN'),
	(3179, 'TN83', 'Tataouine', 'TN'),
	(3180, 'TO02', 'Haapai', 'TO'),
	(3181, 'TO04', 'Tongatapu', 'TO'),
	(3182, 'TO05', 'Vavau', 'TO'),
	(3183, 'TR01', 'Adana', 'TR'),
	(3184, 'TR10', 'Balıkesir', 'TR'),
	(3185, 'TR11', 'Bilecik', 'TR'),
	(3186, 'TR12', 'Bingöl', 'TR'),
	(3187, 'TR13', 'Bitlis', 'TR'),
	(3188, 'TR14', 'Bolu', 'TR'),
	(3189, 'TR15', 'Burdur', 'TR'),
	(3190, 'TR16', 'Bursa', 'TR'),
	(3191, 'TR17', 'Çanakkale', 'TR'),
	(3192, 'TR18', 'Çankırı', 'TR'),
	(3193, 'TR19', 'Çorum', 'TR'),
	(3194, 'TR02', 'Adıyaman', 'TR'),
	(3195, 'TR20', 'Denizli', 'TR'),
	(3196, 'TR21', 'Diyarbakır', 'TR'),
	(3197, 'TR22', 'Edirne', 'TR'),
	(3198, 'TR23', 'Elazığ', 'TR'),
	(3199, 'TR24', 'Erzincan', 'TR'),
	(3200, 'TR25', 'Erzurum', 'TR'),
	(3201, 'TR26', 'Eskişehir', 'TR'),
	(3202, 'TR27', 'Gaziantep', 'TR'),
	(3203, 'TR28', 'Giresun', 'TR'),
	(3204, 'TR29', 'Gümüşhane', 'TR'),
	(3205, 'TR03', 'Afyonkarahisar', 'TR'),
	(3206, 'TR30', 'Hakkari', 'TR'),
	(3207, 'TR31', 'Hatay', 'TR'),
	(3208, 'TR32', 'Isparta', 'TR'),
	(3209, 'TR33', 'Mersin', 'TR'),
	(3210, 'TR34', 'Istanbul', 'TR'),
	(3211, 'TR35', 'Izmir', 'TR'),
	(3212, 'TR36', 'Kars', 'TR'),
	(3213, 'TR37', 'Kastamonu', 'TR'),
	(3214, 'TR38', 'Kayseri', 'TR'),
	(3215, 'TR39', 'Kırklareli', 'TR'),
	(3216, 'TR04', 'Ağrı', 'TR'),
	(3217, 'TR40', 'Kirsehir', 'TR'),
	(3218, 'TR41', 'Kocaeli', 'TR'),
	(3219, 'TR42', 'Konya', 'TR'),
	(3220, 'TR43', 'Kütahya', 'TR'),
	(3221, 'TR44', 'Malatya', 'TR'),
	(3222, 'TR45', 'Manisa', 'TR'),
	(3223, 'TR46', 'Kahramanmaraş', 'TR'),
	(3224, 'TR47', 'Mardin', 'TR'),
	(3225, 'TR48', 'Muğla', 'TR'),
	(3226, 'TR49', 'Muş', 'TR'),
	(3227, 'TR05', 'Amasya', 'TR'),
	(3228, 'TR50', 'Nevşehir', 'TR'),
	(3229, 'TR51', 'Niğde', 'TR'),
	(3230, 'TR52', 'Ordu', 'TR'),
	(3231, 'TR53', 'Rize', 'TR'),
	(3232, 'TR54', 'Sakarya', 'TR'),
	(3233, 'TR55', 'Samsun', 'TR'),
	(3234, 'TR56', 'Siirt', 'TR'),
	(3235, 'TR57', 'Sinop', 'TR'),
	(3236, 'TR58', 'Sivas', 'TR'),
	(3237, 'TR59', 'Tekirdağ', 'TR'),
	(3238, 'TR06', 'Ankara', 'TR'),
	(3239, 'TR60', 'Tokat', 'TR'),
	(3240, 'TR61', 'Trabzon', 'TR'),
	(3241, 'TR62', 'Tunceli', 'TR'),
	(3242, 'TR63', 'Şanlıurfa', 'TR'),
	(3243, 'TR64', 'Uşak', 'TR'),
	(3244, 'TR65', 'Van', 'TR'),
	(3245, 'TR66', 'Yozgat', 'TR'),
	(3246, 'TR67', 'Zonguldak', 'TR'),
	(3247, 'TR68', 'Aksaray', 'TR'),
	(3248, 'TR69', 'Bayburt', 'TR'),
	(3249, 'TR07', 'Antalya', 'TR'),
	(3250, 'TR70', 'Karaman', 'TR');
INSERT INTO public.sehir VALUES
	(3251, 'TR71', 'Kırıkkale', 'TR'),
	(3252, 'TR72', 'Batman', 'TR'),
	(3253, 'TR73', 'Şırnak', 'TR'),
	(3254, 'TR74', 'Bartın', 'TR'),
	(3255, 'TR75', 'Ardahan', 'TR'),
	(3256, 'TR76', 'Iğdır', 'TR'),
	(3257, 'TR77', 'Yalova', 'TR'),
	(3258, 'TR78', 'Karabük', 'TR'),
	(3259, 'TR79', 'Kilis', 'TR'),
	(3260, 'TR08', 'Artvin', 'TR'),
	(3261, 'TR80', 'Osmaniye', 'TR'),
	(3262, 'TR81', 'Düzce', 'TR'),
	(3263, 'TR09', 'Aydın', 'TR'),
	(3264, 'TTARI', 'Arima', 'TT'),
	(3265, 'TTCHA', 'Chaguanas', 'TT'),
	(3266, 'TTCTT', 'Couva-Tabaquite-Talparo', 'TT'),
	(3267, 'TTDMN', 'Diego Martin', 'TT'),
	(3268, 'TTMRC', 'Mayaro-Rio Claro', 'TT'),
	(3269, 'TTPED', 'Penal-Debe', 'TT'),
	(3270, 'TTPOS', 'Port of Spain', 'TT'),
	(3271, 'TTPRT', 'Princes Town', 'TT'),
	(3272, 'TTPTF', 'Point Fortin', 'TT'),
	(3273, 'TTSFO', 'San Fernando', 'TT'),
	(3274, 'TTSGE', 'Sangre Grande', 'TT'),
	(3275, 'TTSIP', 'Siparia', 'TT'),
	(3276, 'TTSJL', 'San Juan-Laventille', 'TT'),
	(3277, 'TTTOB', 'Tobago', 'TT'),
	(3278, 'TTTUP', 'Tunapuna-Piarco', 'TT'),
	(3279, 'TVFUN', 'Funafuti', 'TV'),
	(3280, NULL, 'Changhua', 'TW'),
	(3281, 'TWCYQ', 'Chiayi', 'TW'),
	(3282, 'TWHSQ', 'Hsinchu', 'TW'),
	(3283, 'TWHUA', 'Hualien', 'TW'),
	(3284, 'TWILA', 'Yilan', 'TW'),
	(3285, 'TWKEE', 'Keelung', 'TW'),
	(3286, 'TWKHH', 'Kaohsiung', 'TW'),
	(3287, 'TWKIN', 'Kinmen', 'TW'),
	(3288, 'TWLIE', 'Lienchiang', 'TW'),
	(3289, 'TWMIA', 'Miaoli', 'TW'),
	(3290, 'TWNAN', 'Nantou', 'TW'),
	(3291, 'TWNWT', 'New Taipei', 'TW'),
	(3292, 'TWPEN', 'Penghu', 'TW'),
	(3293, 'TWPIF', 'Pingtung', 'TW'),
	(3294, 'TWTAO', 'Taoyuan', 'TW'),
	(3295, 'TWTNN', 'Tainan', 'TW'),
	(3296, 'TWTPE', 'Taipei', 'TW'),
	(3297, 'TWTTT', 'Taitung', 'TW'),
	(3298, 'TWTXG', 'Taichung', 'TW'),
	(3299, 'TWYUN', 'Yunlin', 'TW'),
	(3300, 'TZ01', 'Arusha', 'TZ'),
	(3301, 'TZ02', 'Dar es Salaam', 'TZ'),
	(3302, 'TZ03', 'Dodoma', 'TZ'),
	(3303, 'TZ04', 'Iringa', 'TZ'),
	(3304, 'TZ05', 'Kagera', 'TZ'),
	(3305, 'TZ06', 'Kaskazini Pemba', 'TZ'),
	(3306, 'TZ07', 'Kaskazini Unguja', 'TZ'),
	(3307, 'TZ08', 'Kigoma', 'TZ'),
	(3308, 'TZ09', 'Kilimanjaro', 'TZ'),
	(3309, 'TZ10', 'Kusini Pemba', 'TZ'),
	(3310, 'TZ11', 'Kusini Unguja', 'TZ'),
	(3311, 'TZ12', 'Lindi', 'TZ'),
	(3312, 'TZ13', 'Mara', 'TZ'),
	(3313, 'TZ14', 'Mbeya', 'TZ'),
	(3314, 'TZ15', 'Mjini Magharibi', 'TZ'),
	(3315, 'TZ16', 'Morogoro', 'TZ'),
	(3316, 'TZ17', 'Mtwara', 'TZ'),
	(3317, 'TZ18', 'Mwanza', 'TZ'),
	(3318, 'TZ19', 'Pwani', 'TZ'),
	(3319, 'TZ20', 'Rukwa', 'TZ'),
	(3320, 'TZ21', 'Ruvuma', 'TZ'),
	(3321, 'TZ22', 'Shinyanga', 'TZ'),
	(3322, 'TZ23', 'Singida', 'TZ'),
	(3323, 'TZ24', 'Tabora', 'TZ'),
	(3324, 'TZ25', 'Tanga', 'TZ'),
	(3325, 'TZ26', 'Manyara', 'TZ'),
	(3326, 'UA05', 'Vinnytska oblast', 'UA'),
	(3327, 'UA07', 'Volynska oblast', 'UA'),
	(3328, 'UA09', 'Luhanska oblast', 'UA'),
	(3329, 'UA12', 'Dnipropetrovska oblast', 'UA'),
	(3330, 'UA14', 'Donetska oblast', 'UA'),
	(3331, 'UA18', 'Zhytomyrska oblast', 'UA'),
	(3332, 'UA21', 'Zakarpatska oblast', 'UA'),
	(3333, 'UA23', 'Zaporizka oblast', 'UA'),
	(3334, 'UA26', 'Ivano-Frankivska oblast', 'UA'),
	(3335, 'UA30', 'Kyiv', 'UA'),
	(3336, 'UA32', 'Kyivska oblast', 'UA'),
	(3337, 'UA35', 'Kirovohradska oblast', 'UA'),
	(3338, 'UA40', 'Sevastopol', 'UA'),
	(3339, 'UA43', 'Avtonomna Respublika Krym', 'UA'),
	(3340, 'UA46', 'Lvivska oblast', 'UA'),
	(3341, 'UA48', 'Mykolaivska oblast', 'UA'),
	(3342, 'UA51', 'Odeska oblast', 'UA'),
	(3343, 'UA53', 'Poltavska oblast', 'UA'),
	(3344, 'UA56', 'Rivnenska oblast', 'UA'),
	(3345, 'UA59', 'Sumska oblast', 'UA'),
	(3346, 'UA61', 'Ternopilska oblast', 'UA'),
	(3347, 'UA63', 'Kharkivska oblast', 'UA'),
	(3348, 'UA65', 'Khersonska oblast', 'UA'),
	(3349, 'UA68', 'Khmelnytska oblast', 'UA'),
	(3350, 'UA71', 'Cherkaska oblast', 'UA'),
	(3351, 'UA74', 'Chernihivska oblast', 'UA'),
	(3352, 'UA77', 'Chernivetska oblast', 'UA'),
	(3353, 'UG101', 'Kalangala', 'UG'),
	(3354, 'UG102', 'Kampala', 'UG'),
	(3355, 'UG103', 'Kiboga', 'UG'),
	(3356, 'UG104', 'Luwero', 'UG'),
	(3357, 'UG105', 'Masaka', 'UG'),
	(3358, 'UG106', 'Mpigi', 'UG'),
	(3359, 'UG107', 'Mubende', 'UG'),
	(3360, 'UG108', 'Mukono', 'UG'),
	(3361, 'UG109', 'Nakasongola', 'UG'),
	(3362, 'UG110', 'Rakai', 'UG'),
	(3363, 'UG111', 'Sembabule', 'UG'),
	(3364, 'UG112', 'Kayunga', 'UG'),
	(3365, 'UG113', 'Wakiso', 'UG'),
	(3366, 'UG114', 'Mityana', 'UG'),
	(3367, 'UG115', 'Nakaseke', 'UG'),
	(3368, 'UG116', 'Lyantonde', 'UG'),
	(3369, 'UG117', 'Buikwe', 'UG'),
	(3370, 'UG118', 'Bukomansibi', 'UG'),
	(3371, 'UG120', 'Buvuma', 'UG'),
	(3372, 'UG121', 'Gomba', 'UG'),
	(3373, 'UG123', 'Kyankwanzi', 'UG'),
	(3374, 'UG124', 'Lwengo', 'UG'),
	(3375, 'UG201', 'Bugiri', 'UG'),
	(3376, 'UG202', 'Busia', 'UG'),
	(3377, 'UG203', 'Iganga', 'UG'),
	(3378, 'UG204', 'Jinja', 'UG'),
	(3379, 'UG205', 'Kamuli', 'UG'),
	(3380, 'UG206', 'Kapchorwa', 'UG'),
	(3381, 'UG207', 'Katakwi', 'UG'),
	(3382, 'UG208', 'Kumi', 'UG'),
	(3383, 'UG209', 'Mbale', 'UG'),
	(3384, 'UG210', 'Pallisa', 'UG'),
	(3385, 'UG211', 'Soroti', 'UG'),
	(3386, 'UG212', 'Tororo', 'UG'),
	(3387, 'UG213', 'Kaberamaido', 'UG'),
	(3388, 'UG214', 'Mayuge', 'UG'),
	(3389, 'UG215', 'Sironko', 'UG'),
	(3390, 'UG216', 'Amuria', 'UG'),
	(3391, 'UG217', 'Budaka', 'UG'),
	(3392, 'UG218', 'Bukwa', 'UG'),
	(3393, 'UG219', 'Butaleja', 'UG'),
	(3394, 'UG220', 'Kaliro', 'UG'),
	(3395, 'UG221', 'Manafwa', 'UG'),
	(3396, 'UG222', 'Namutumba', 'UG'),
	(3397, 'UG223', 'Bududa', 'UG'),
	(3398, 'UG224', 'Bukedea', 'UG'),
	(3399, 'UG225', 'Bulambuli', 'UG'),
	(3400, 'UG226', 'Buyende', 'UG'),
	(3401, 'UG227', 'Kibuku', 'UG'),
	(3402, 'UG228', 'Kween', 'UG'),
	(3403, 'UG229', 'Luuka', 'UG'),
	(3404, 'UG230', 'Namayingo', 'UG'),
	(3405, 'UG231', 'Ngora', 'UG'),
	(3406, 'UG232', 'Serere', 'UG'),
	(3407, 'UG301', 'Adjumani', 'UG'),
	(3408, 'UG302', 'Apac', 'UG'),
	(3409, 'UG303', 'Arua', 'UG'),
	(3410, 'UG304', 'Gulu', 'UG'),
	(3411, 'UG305', 'Kitgum', 'UG'),
	(3412, 'UG306', 'Kotido', 'UG'),
	(3413, 'UG307', 'Lira', 'UG'),
	(3414, 'UG308', 'Moroto', 'UG'),
	(3415, 'UG309', 'Moyo', 'UG'),
	(3416, 'UG310', 'Nebbi', 'UG'),
	(3417, 'UG311', 'Nakapiripirit', 'UG'),
	(3418, 'UG312', 'Pader', 'UG'),
	(3419, 'UG313', 'Yumbe', 'UG'),
	(3420, 'UG314', 'Amolatar', 'UG'),
	(3421, 'UG315', 'Kaabong', 'UG'),
	(3422, 'UG316', 'Koboko', 'UG'),
	(3423, 'UG317', 'Abim', 'UG'),
	(3424, 'UG318', 'Dokolo', 'UG'),
	(3425, 'UG319', 'Amuru', 'UG'),
	(3426, 'UG320', 'Maracha', 'UG'),
	(3427, 'UG321', 'Oyam', 'UG'),
	(3428, 'UG322', 'Agago', 'UG'),
	(3429, 'UG323', 'Alebtong', 'UG'),
	(3430, 'UG324', 'Amudat', 'UG'),
	(3431, 'UG326', 'Kole', 'UG'),
	(3432, 'UG328', 'Napak', 'UG'),
	(3433, 'UG330', 'Otuke', 'UG'),
	(3434, 'UG331', 'Zombo', 'UG'),
	(3435, 'UG401', 'Bundibugyo', 'UG'),
	(3436, 'UG402', 'Bushenyi', 'UG'),
	(3437, 'UG403', 'Hoima', 'UG'),
	(3438, 'UG404', 'Kabale', 'UG'),
	(3439, 'UG405', 'Kabarole', 'UG'),
	(3440, 'UG406', 'Kasese', 'UG'),
	(3441, 'UG407', 'Kibaale', 'UG'),
	(3442, 'UG408', 'Kisoro', 'UG'),
	(3443, 'UG409', 'Masindi', 'UG'),
	(3444, 'UG410', 'Mbarara', 'UG'),
	(3445, 'UG411', 'Ntungamo', 'UG'),
	(3446, 'UG412', 'Rukungiri', 'UG'),
	(3447, 'UG413', 'Kamwenge', 'UG'),
	(3448, 'UG414', 'Kanungu', 'UG'),
	(3449, 'UG415', 'Kyenjojo', 'UG'),
	(3450, 'UG417', 'Isingiro', 'UG'),
	(3451, 'UG419', 'Buliisa', 'UG'),
	(3452, 'UG420', 'Kiryandongo', 'UG'),
	(3453, 'UG421', 'Kyegegwa', 'UG'),
	(3454, 'UG422', 'Mitooma', 'UG'),
	(3455, 'UG423', 'Ntoroko', 'UG'),
	(3456, 'UG424', 'Rubirizi', 'UG'),
	(3457, 'UG425', 'Sheema', 'UG'),
	(3458, 'UM95', 'Palmyra Atoll', 'UM'),
	(3459, 'USAK', 'Alaska', 'US'),
	(3460, 'USAL', 'Alabama', 'US'),
	(3461, 'USAR', 'Arkansas', 'US'),
	(3462, 'USAZ', 'Arizona', 'US'),
	(3463, 'USCA', 'California', 'US'),
	(3464, 'USCO', 'Colorado', 'US'),
	(3465, 'USCT', 'Connecticut', 'US'),
	(3466, 'USDC', 'District of Columbia', 'US'),
	(3467, 'USDE', 'Delaware', 'US'),
	(3468, 'USFL', 'Florida', 'US'),
	(3469, 'USGA', 'Georgia', 'US'),
	(3470, 'USHI', 'Hawaii', 'US'),
	(3471, 'USIA', 'Iowa', 'US'),
	(3472, 'USID', 'Idaho', 'US'),
	(3473, 'USIL', 'Illinois', 'US'),
	(3474, 'USIN', 'Indiana', 'US'),
	(3475, 'USKS', 'Kansas', 'US'),
	(3476, 'USKY', 'Kentucky', 'US'),
	(3477, 'USLA', 'Louisiana', 'US'),
	(3478, 'USMA', 'Massachusetts', 'US'),
	(3479, 'USMD', 'Maryland', 'US'),
	(3480, 'USME', 'Maine', 'US'),
	(3481, 'USMI', 'Michigan', 'US'),
	(3482, 'USMN', 'Minnesota', 'US'),
	(3483, 'USMO', 'Missouri', 'US'),
	(3484, 'USMS', 'Mississippi', 'US'),
	(3485, 'USMT', 'Montana', 'US'),
	(3486, 'USNC', 'North Carolina', 'US'),
	(3487, 'USND', 'North Dakota', 'US'),
	(3488, 'USNE', 'Nebraska', 'US'),
	(3489, 'USNH', 'New Hampshire', 'US'),
	(3490, 'USNJ', 'New Jersey', 'US'),
	(3491, 'USNM', 'New Mexico', 'US'),
	(3492, 'USNV', 'Nevada', 'US'),
	(3493, 'USNY', 'New York', 'US'),
	(3494, 'USOH', 'Ohio', 'US'),
	(3495, 'USOK', 'Oklahoma', 'US'),
	(3496, 'USOR', 'Oregon', 'US'),
	(3497, 'USPA', 'Pennsylvania', 'US'),
	(3498, 'USRI', 'Rhode Island', 'US'),
	(3499, 'USSC', 'South Carolina', 'US'),
	(3500, 'USSD', 'South Dakota', 'US');
INSERT INTO public.sehir VALUES
	(3501, 'USTN', 'Tennessee', 'US'),
	(3502, 'USTX', 'Texas', 'US'),
	(3503, 'USUT', 'Utah', 'US'),
	(3504, 'USVA', 'Virginia', 'US'),
	(3505, 'USVT', 'Vermont', 'US'),
	(3506, 'USWA', 'Washington', 'US'),
	(3507, 'USWI', 'Wisconsin', 'US'),
	(3508, 'USWV', 'West Virginia', 'US'),
	(3509, 'USWY', 'Wyoming', 'US'),
	(3510, 'UYAR', 'Artigas', 'UY'),
	(3511, 'UYCA', 'Canelones', 'UY'),
	(3512, 'UYCL', 'Cerro Largo', 'UY'),
	(3513, 'UYCO', 'Colonia', 'UY'),
	(3514, 'UYDU', 'Durazno', 'UY'),
	(3515, 'UYFD', 'Florida', 'UY'),
	(3516, 'UYFS', 'Flores', 'UY'),
	(3517, 'UYLA', 'Lavalleja', 'UY'),
	(3518, 'UYMA', 'Maldonado', 'UY'),
	(3519, 'UYMO', 'Montevideo', 'UY'),
	(3520, 'UYPA', 'Paysandu', 'UY'),
	(3521, 'UYRN', 'Rio Negro', 'UY'),
	(3522, 'UYRO', 'Rocha', 'UY'),
	(3523, 'UYRV', 'Rivera', 'UY'),
	(3524, 'UYSA', 'Salto', 'UY'),
	(3525, 'UYSJ', 'San Jose', 'UY'),
	(3526, 'UYSO', 'Soriano', 'UY'),
	(3527, 'UYTA', 'Tacuarembo', 'UY'),
	(3528, 'UYTT', 'Treinta y Tres', 'UY'),
	(3529, 'UZAN', 'Andijon', 'UZ'),
	(3530, 'UZBU', 'Buxoro', 'UZ'),
	(3531, 'UZFA', 'Fargona', 'UZ'),
	(3532, 'UZJI', 'Jizzax', 'UZ'),
	(3533, 'UZNG', 'Namangan', 'UZ'),
	(3534, 'UZNW', 'Navoiy', 'UZ'),
	(3535, 'UZQA', 'Qashqadaryo', 'UZ'),
	(3536, 'UZQR', 'Qoraqalpogiston Respublikasi', 'UZ'),
	(3537, 'UZSA', 'Samarqand', 'UZ'),
	(3538, 'UZSI', 'Sirdaryo', 'UZ'),
	(3539, 'UZSU', 'Surxondaryo', 'UZ'),
	(3540, 'UZTK', 'Toshkent', 'UZ'),
	(3541, 'UZXO', 'Xorazm', 'UZ'),
	(3542, NULL, 'Vatican City', 'VA'),
	(3543, 'VC01', 'Charlotte', 'VC'),
	(3544, 'VC04', 'Saint George', 'VC'),
	(3545, 'VEA', 'Distrito Capital', 'VE'),
	(3546, 'VEB', 'Anzoategui', 'VE'),
	(3547, 'VEC', 'Apure', 'VE'),
	(3548, 'VED', 'Aragua', 'VE'),
	(3549, 'VEE', 'Barinas', 'VE'),
	(3550, 'VEF', 'Bolivar', 'VE'),
	(3551, 'VEG', 'Carabobo', 'VE'),
	(3552, 'VEH', 'Cojedes', 'VE'),
	(3553, 'VEI', 'Falcon', 'VE'),
	(3554, 'VEJ', 'Guarico', 'VE'),
	(3555, 'VEK', 'Lara', 'VE'),
	(3556, 'VEL', 'Merida', 'VE'),
	(3557, 'VEM', 'Miranda', 'VE'),
	(3558, 'VEN', 'Monagas', 'VE'),
	(3559, 'VEO', 'Nueva Esparta', 'VE'),
	(3560, 'VEP', 'Portuguesa', 'VE'),
	(3561, 'VER', 'Sucre', 'VE'),
	(3562, 'VES', 'Tachira', 'VE'),
	(3563, 'VET', 'Trujillo', 'VE'),
	(3564, 'VEU', 'Yaracuy', 'VE'),
	(3565, 'VEV', 'Zulia', 'VE'),
	(3566, 'VEX', 'Vargas', 'VE'),
	(3567, 'VEY', 'Delta Amacuro', 'VE'),
	(3568, 'VEZ', 'Amazonas', 'VE'),
	(3569, NULL, 'British Virgin Islands', 'VG'),
	(3570, NULL, 'Virgin Islands', 'VI'),
	(3571, 'VN01', 'Lai Chau', 'VN'),
	(3572, 'VN02', 'Lao Cai', 'VN'),
	(3573, 'VN03', 'Ha Giang', 'VN'),
	(3574, 'VN04', 'Cao Bang', 'VN'),
	(3575, 'VN05', 'Son La', 'VN'),
	(3576, 'VN06', 'Yen Bai', 'VN'),
	(3577, 'VN07', 'Tuyen Quang', 'VN'),
	(3578, 'VN09', 'Lang Son', 'VN'),
	(3579, 'VN13', 'Quang Ninh', 'VN'),
	(3580, 'VN14', 'Hoa Binh', 'VN'),
	(3581, 'VN18', 'Ninh Binh', 'VN'),
	(3582, 'VN20', 'Thai Binh', 'VN'),
	(3583, 'VN21', 'Thanh Hoa', 'VN'),
	(3584, 'VN22', 'Nghe An', 'VN'),
	(3585, 'VN23', 'Ha Tinh', 'VN'),
	(3586, 'VN24', 'Quang Binh', 'VN'),
	(3587, 'VN25', 'Quang Tri', 'VN'),
	(3588, 'VN26', 'Thua Thien-Hue', 'VN'),
	(3589, 'VN27', 'Quang Nam', 'VN'),
	(3590, 'VN29', 'Quang Ngai', 'VN'),
	(3591, 'VN30', 'Gia Lai', 'VN'),
	(3592, 'VN31', 'Binh Dinh', 'VN'),
	(3593, 'VN32', 'Phu Yen', 'VN'),
	(3594, 'VN33', 'Dak Lak', 'VN'),
	(3595, 'VN34', 'Khanh Hoa', 'VN'),
	(3596, 'VN35', 'Lam Dong', 'VN'),
	(3597, 'VN36', 'Ninh Thuan', 'VN'),
	(3598, 'VN37', 'Tay Ninh', 'VN'),
	(3599, 'VN39', 'Dong Nai', 'VN'),
	(3600, 'VN40', 'Binh Thuan', 'VN'),
	(3601, 'VN41', 'Long An', 'VN'),
	(3602, 'VN44', 'An Giang', 'VN'),
	(3603, 'VN45', 'Dong Thap', 'VN'),
	(3604, 'VN46', 'Tien Giang', 'VN'),
	(3605, 'VN47', 'Kien Giang', 'VN'),
	(3606, 'VN49', 'Vinh Long', 'VN'),
	(3607, 'VN50', 'Ben Tre', 'VN'),
	(3608, 'VN51', 'Tra Vinh', 'VN'),
	(3609, 'VN52', 'Soc Trang', 'VN'),
	(3610, 'VN53', 'Bac Kan', 'VN'),
	(3611, 'VN54', 'Bac Giang', 'VN'),
	(3612, 'VN55', 'Bac Lieu', 'VN'),
	(3613, 'VN56', 'Bac Ninh', 'VN'),
	(3614, 'VN57', 'Binh Duong', 'VN'),
	(3615, 'VN58', 'Binh Phuoc', 'VN'),
	(3616, 'VN59', 'Ca Mau', 'VN'),
	(3617, 'VN61', 'Hai Duong', 'VN'),
	(3618, 'VN63', 'Ha Nam', 'VN'),
	(3619, 'VN66', 'Hung Yen', 'VN'),
	(3620, 'VN67', 'Nam Dinh', 'VN'),
	(3621, 'VN68', 'Phu Tho', 'VN'),
	(3622, 'VN69', 'Thai Nguyen', 'VN'),
	(3623, 'VN70', 'Vinh Phuc', 'VN'),
	(3624, 'VN71', 'Dien Bien', 'VN'),
	(3625, 'VNCT', 'Can Tho', 'VN'),
	(3626, 'VNDN', 'Da Nang', 'VN'),
	(3627, 'VNHN', 'Ha Noi', 'VN'),
	(3628, 'VNHP', 'Hai Phong', 'VN'),
	(3629, 'VNSG', 'Ho Chi Minh', 'VN'),
	(3630, 'VUMAP', 'Malampa', 'VU'),
	(3631, 'VUSAM', 'Sanma', 'VU'),
	(3632, 'VUSEE', 'Shefa', 'VU'),
	(3633, 'VUTAE', 'Tafea', 'VU'),
	(3634, 'VUTOB', 'Torba', 'VU'),
	(3635, 'WFUV', 'Uvea', 'WF'),
	(3636, 'WSAA', 'Aana', 'WS'),
	(3637, 'WSAT', 'Atua', 'WS'),
	(3638, 'WSGI', 'Gagaifomauga', 'WS'),
	(3639, 'WSPA', 'Palauli', 'WS'),
	(3640, 'WSTU', 'Tuamasaga', 'WS'),
	(3641, 'YEAB', 'Abyan', 'YE'),
	(3642, 'YEAD', 'Adan', 'YE'),
	(3643, 'YEAM', 'Amran', 'YE'),
	(3644, 'YEBA', 'Al Bayda', 'YE'),
	(3645, 'YEDA', 'Ad Dali', 'YE'),
	(3646, 'YEDH', 'Dhamar', 'YE'),
	(3647, 'YEHD', 'Hadramawt', 'YE'),
	(3648, 'YEHJ', 'Hajjah', 'YE'),
	(3649, 'YEHU', 'Al Hudaydah', 'YE'),
	(3650, 'YEIB', 'Ibb', 'YE'),
	(3651, 'YEJA', 'Al Jawf', 'YE'),
	(3652, 'YELA', 'Lahij', 'YE'),
	(3653, 'YEMA', 'Marib', 'YE'),
	(3654, 'YEMR', 'Al Mahrah', 'YE'),
	(3655, 'YEMW', 'Al Mahwit', 'YE'),
	(3656, 'YERA', 'Raymah', 'YE'),
	(3657, 'YESA', 'Amanat al Asimah', 'YE'),
	(3658, 'YESD', 'Sadah', 'YE'),
	(3659, 'YESH', 'Shabwah', 'YE'),
	(3660, 'YESN', 'Sana', 'YE'),
	(3661, 'YETA', 'Taizz', 'YE'),
	(3662, NULL, 'Acoua', 'YT'),
	(3663, NULL, 'Bandraboua', 'YT'),
	(3664, NULL, 'Bandrele', 'YT'),
	(3665, NULL, 'Boueni', 'YT'),
	(3666, NULL, 'Chiconi', 'YT'),
	(3667, NULL, 'Chirongui', 'YT'),
	(3668, NULL, 'Dzaoudzi', 'YT'),
	(3669, NULL, 'Kani-Keli', 'YT'),
	(3670, NULL, 'Koungou', 'YT'),
	(3671, NULL, 'Mamoudzou', 'YT'),
	(3672, NULL, 'Mtsamboro', 'YT'),
	(3673, NULL, 'Ouangani', 'YT'),
	(3674, NULL, 'Pamandzi', 'YT'),
	(3675, NULL, 'Sada', 'YT'),
	(3676, NULL, 'Tsingoni', 'YT'),
	(3677, 'ZAEC', 'Eastern Cape', 'ZA'),
	(3678, 'ZAFS', 'Free State', 'ZA'),
	(3679, 'ZAGT', 'Gauteng', 'ZA'),
	(3680, 'ZALP', 'Limpopo', 'ZA'),
	(3681, 'ZAMP', 'Mpumalanga', 'ZA'),
	(3682, 'ZANC', 'Northern Cape', 'ZA'),
	(3683, 'ZANL', 'Kwazulu-Natal', 'ZA'),
	(3684, 'ZANW', 'North-West', 'ZA'),
	(3685, 'ZAWC', 'Western Cape', 'ZA'),
	(3686, 'ZM01', 'Western', 'ZM'),
	(3687, 'ZM02', 'Central', 'ZM'),
	(3688, 'ZM03', 'Eastern', 'ZM'),
	(3689, 'ZM04', 'Luapula', 'ZM'),
	(3690, 'ZM05', 'Northern', 'ZM'),
	(3691, 'ZM06', 'North-Western', 'ZM'),
	(3692, 'ZM07', 'Southern', 'ZM'),
	(3693, 'ZM08', 'Copperbelt', 'ZM'),
	(3694, 'ZM09', 'Lusaka', 'ZM'),
	(3695, 'ZWBU', 'Bulawayo', 'ZW'),
	(3696, 'ZWHA', 'Harare', 'ZW'),
	(3697, 'ZWMA', 'Manicaland', 'ZW'),
	(3698, 'ZWMC', 'Mashonaland Central', 'ZW'),
	(3699, 'ZWME', 'Mashonaland East', 'ZW'),
	(3700, 'ZWMI', 'Midlands', 'ZW'),
	(3701, 'ZWMN', 'Matabeleland North', 'ZW'),
	(3702, 'ZWMS', 'Matabeleland South', 'ZW'),
	(3703, 'ZWMV', 'Masvingo', 'ZW'),
	(3704, 'asdf sghf', 'f hdfh  dfjh', NULL),
	(3705, 'ZWMW', 'Mashonaland West', 'ZW'),
	(3706, 'dsfgs hjk', 'ghj fgjh', NULL),
	(3707, 'edfghnjö', 'fghjgf hjfh', NULL);


--
-- Data for Name: siparis_detay; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.siparis_detay VALUES
	(2, 221, 34, 20, 'TL', 5),
	(3, 221, 25, 100, 'TL', 2),
	(4, 221, 33, 80, 'TL', 2);


--
-- Data for Name: siparisler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.siparisler VALUES
	(1, 23123, NULL, NULL, NULL, NULL, NULL, NULL, 'wrwrtwet'),
	(2, 11111, NULL, NULL, NULL, NULL, NULL, NULL, 'sdeedeeeee'),
	(3, 11222, NULL, NULL, NULL, NULL, NULL, NULL, 'ddffffff'),
	(4, 434546, NULL, NULL, NULL, NULL, NULL, NULL, 'asdfzdghj'),
	(5, 20, NULL, NULL, NULL, NULL, NULL, NULL, 'açıkalama'),
	(6, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asad'),
	(7, 0, NULL, NULL, NULL, NULL, NULL, NULL, ''),
	(8, 0, NULL, NULL, NULL, NULL, NULL, NULL, ''),
	(9, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sadas'),
	(10, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asdas'),
	(11, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(12, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asda'),
	(13, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(14, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(15, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asda'),
	(16, 0, NULL, NULL, NULL, NULL, NULL, NULL, ''),
	(17, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(18, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asdasd'),
	(19, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(20, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(21, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(22, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(23, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(24, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(25, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(26, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(27, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(28, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(29, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asda'),
	(30, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(31, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(32, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(33, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(34, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(35, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(36, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(37, 0, NULL, NULL, NULL, NULL, NULL, NULL, ''),
	(38, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(39, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(40, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(41, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asda'),
	(42, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(43, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(44, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sads'),
	(45, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asdd'),
	(46, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(47, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(48, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(49, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(50, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(51, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(52, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(53, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(54, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(55, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(56, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(57, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asda'),
	(58, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sd'),
	(59, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asda'),
	(60, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(61, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asdas'),
	(62, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(63, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(64, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asda'),
	(65, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(66, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(67, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(68, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(69, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(70, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(71, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(72, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(73, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(74, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(75, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(76, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(77, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'as'),
	(78, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(79, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(80, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(81, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(82, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(83, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'as'),
	(84, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(85, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(86, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asdsa'),
	(87, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(88, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(89, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(90, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(91, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(92, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(93, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(94, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(95, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(96, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(97, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(98, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(99, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(100, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(101, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(102, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(103, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(104, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(105, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(106, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(107, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(108, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(109, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(110, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(111, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(112, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(113, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(114, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(115, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(116, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(117, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(118, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(119, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(120, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(121, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(122, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(123, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(124, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(125, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(126, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(127, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(128, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(129, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(130, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(131, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(132, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(133, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(134, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(135, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(136, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(137, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(138, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(139, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(140, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(141, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(142, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(143, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(144, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(145, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(146, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(147, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(148, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(149, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(150, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(151, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(152, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(153, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(154, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(155, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(156, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(157, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(158, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(159, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(160, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(161, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(162, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(163, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(164, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(165, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(166, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(167, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(168, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(169, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(170, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(171, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(172, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(173, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(174, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(175, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(176, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(177, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(178, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'aasd'),
	(179, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(180, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(181, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(182, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(183, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(184, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(185, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(186, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(187, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(188, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(189, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(190, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(191, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(192, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(193, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(194, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(195, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(196, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(197, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(198, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(199, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(200, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(201, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(202, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(203, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(204, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(205, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(206, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(207, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(208, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(209, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(210, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'sad'),
	(211, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(212, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(213, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(214, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(215, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(216, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(217, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(218, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'ghdfjh'),
	(219, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asdfd'),
	(220, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'asd'),
	(221, 20, NULL, 150, 'TL', '2020-10-08 00:00:00', NULL, NULL, NULL);


--
-- Data for Name: taksit; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ulke; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ulke VALUES
	(1, 'DE', 'Almanya'),
	(2, 'AD', 'Andorra'),
	(3, 'AO', 'Angola'),
	(4, 'AG', 'Antigua ve Barbuda'),
	(5, 'AR', 'Arjantin'),
	(6, 'AL', 'Arnavutluk'),
	(7, 'AW', 'Aruba'),
	(8, 'AU', 'Avustralya'),
	(9, 'AT', 'Avusturya'),
	(10, 'AZ', 'Azerbaycan'),
	(11, 'BS', 'Bahamalar'),
	(12, 'BH', 'Bahreyn'),
	(13, 'BD', 'Banglades'),
	(14, 'BB', 'Barbados'),
	(15, 'EH', 'Bati Sahra (MA)'),
	(16, 'BE', 'Belçika'),
	(17, 'BZ', 'Belize'),
	(18, 'BJ', 'Benin'),
	(19, 'BM', 'Bermuda'),
	(20, 'BY', 'Beyaz Rusya'),
	(21, 'BT', 'Bhutan'),
	(22, 'AE', 'Birlesik Arap Emirlikleri'),
	(23, 'US', 'Birlesik Devletler'),
	(24, 'GB', 'Birlesik Krallik'),
	(25, 'BO', 'Bolivya'),
	(26, 'BA', 'Bosna-Hersek'),
	(27, 'BW', 'Botsvana'),
	(28, 'BR', 'Brezilya'),
	(29, 'BN', 'Bruney'),
	(30, 'BG', 'Bulgaristan'),
	(31, 'BF', 'Burkina Faso'),
	(32, 'BI', 'Burundi'),
	(33, 'TD', 'Çad'),
	(34, 'KY', 'Cayman Adalari'),
	(35, 'GI', 'Cebelitarik (GB)'),
	(36, 'CZ', 'Çek Cumhuriyeti'),
	(37, 'DZ', 'Cezayir'),
	(38, 'DJ', 'Cibuti'),
	(39, 'CN', 'Çin'),
	(40, 'DK', 'Danimarka'),
	(41, 'CD', 'Demokratik Kongo Cumhuriyeti'),
	(42, 'TL', 'Dogu Timor'),
	(43, 'DO', 'Dominik Cumhuriyeti'),
	(44, 'DM', 'Dominika'),
	(45, 'EC', 'Ekvador'),
	(46, 'GQ', 'Ekvator Ginesi'),
	(47, 'SV', 'El Salvador'),
	(48, 'ID', 'Endonezya'),
	(49, 'ER', 'Eritre'),
	(50, 'AM', 'Ermenistan'),
	(51, 'MF', 'Ermis Martin (FR)'),
	(52, 'EE', 'Estonya'),
	(53, 'ET', 'Etiyopya'),
	(54, 'FK', 'Falkland Adalari'),
	(55, 'FO', 'Faroe Adalari (DK)'),
	(56, 'MA', 'Fas'),
	(57, 'FJ', 'Fiji'),
	(58, 'CI', 'Fildisi Sahili'),
	(59, 'PH', 'Filipinler'),
	(60, 'PS', 'Filistin'),
	(61, 'FI', 'Finlandiya'),
	(62, 'FR', 'Fransa'),
	(63, 'GF', 'Fransiz Guyanasi (FR)'),
	(64, 'PF', 'Fransiz Polinezyasi (FR)'),
	(65, 'GA', 'Gabon'),
	(66, 'GM', 'Gambiya'),
	(67, 'GH', 'Gana'),
	(68, 'GN', 'Gine'),
	(69, 'GW', 'Gine Bissau'),
	(70, 'GD', 'Grenada'),
	(71, 'GL', 'Grönland (DK)'),
	(72, 'GP', 'Guadeloupe (FR)'),
	(73, 'GT', 'Guatemala'),
	(74, 'GG', 'Guernsey (GB)'),
	(75, 'ZA', 'Güney Afrika'),
	(76, 'KR', 'Güney Kore'),
	(77, 'GE', 'Gürcistan'),
	(78, 'GY', 'Guyana'),
	(79, 'HT', 'Haiti'),
	(80, 'IN', 'Hindistan'),
	(81, 'HR', 'Hirvatistan'),
	(82, 'NL', 'Hollanda'),
	(83, 'HN', 'Honduras'),
	(84, 'HK', 'Hong Kong (CN)'),
	(85, 'VG', 'Ingiliz Virjin Adalari'),
	(86, 'IQ', 'Irak'),
	(87, 'IR', 'Iran'),
	(88, 'IE', 'Irlanda'),
	(89, 'ES', 'Ispanya'),
	(90, 'IL', 'Israil'),
	(91, 'SE', 'Isveç'),
	(92, 'CH', 'Isviçre'),
	(93, 'IT', 'Italya'),
	(94, 'IS', 'Izlanda'),
	(95, 'JM', 'Jamaika'),
	(96, 'JP', 'Japonya'),
	(97, 'JE', 'Jersey (GB)'),
	(98, 'KK', 'K.K.T.C'),
	(99, 'KH', 'Kamboçya'),
	(100, 'CM', 'Kamerun'),
	(101, 'CA', 'Kanada'),
	(102, 'ME', 'Karadag'),
	(103, 'QA', 'Katar'),
	(104, 'KZ', 'Kazakistan'),
	(105, 'KE', 'Kenya'),
	(106, 'CY', 'Kibris'),
	(107, 'KG', 'Kirgizistan'),
	(108, 'KI', 'Kiribati'),
	(109, 'CO', 'Kolombiya'),
	(110, 'KM', 'Komorlar'),
	(111, 'CG', 'Kongo Cumhuriyeti'),
	(112, 'KV', 'Kosova (RS)'),
	(113, 'CR', 'Kosta Rika'),
	(114, 'CU', 'Küba'),
	(115, 'KW', 'Kuveyt'),
	(116, 'KP', 'Kuzey Kore'),
	(117, 'LA', 'Laos'),
	(118, 'LS', 'Lesoto'),
	(119, 'LV', 'Letonya'),
	(120, 'LR', 'Liberya'),
	(121, 'LY', 'Libya'),
	(122, 'LI', 'Lihtenstayn'),
	(123, 'LT', 'Litvanya'),
	(124, 'LB', 'Lübnan'),
	(125, 'LU', 'Lüksemburg'),
	(126, 'HU', 'Macaristan'),
	(127, 'MG', 'Madagaskar'),
	(128, 'MO', 'Makao (CN)'),
	(129, 'MK', 'Makedonya'),
	(130, 'MW', 'Malavi'),
	(131, 'MV', 'Maldivler'),
	(132, 'MY', 'Malezya'),
	(133, 'ML', 'Mali'),
	(134, 'MT', 'Malta'),
	(135, 'IM', 'Man Adasi (GB)'),
	(136, 'MH', 'Marshall Adalari'),
	(137, 'MQ', 'Martinique (FR)'),
	(138, 'MU', 'Mauritius'),
	(139, 'YT', 'Mayotte (FR)'),
	(140, 'MX', 'Meksika'),
	(141, 'FM', 'Mikronezya'),
	(142, 'EG', 'Misir'),
	(143, 'MN', 'Mogolistan'),
	(144, 'MD', 'Moldova'),
	(145, 'MC', 'Monako'),
	(146, 'MR', 'Moritanya'),
	(147, 'MZ', 'Mozambik'),
	(148, 'MM', 'Myanmar'),
	(149, 'NA', 'Namibya'),
	(150, 'NR', 'Nauru'),
	(151, 'NP', 'Nepal'),
	(152, 'NE', 'Nijer'),
	(153, 'NG', 'Nijerya'),
	(154, 'NI', 'Nikaragua'),
	(155, 'NO', 'Norveç'),
	(156, 'CF', 'Orta Afrika Cumhuriyeti'),
	(157, 'UZ', 'Özbekistan'),
	(158, 'PK', 'Pakistan'),
	(159, 'PW', 'Palau'),
	(160, 'PA', 'Panama'),
	(161, 'PG', 'Papua Yeni Gine'),
	(162, 'PY', 'Paraguay'),
	(163, 'PE', 'Peru'),
	(164, 'PL', 'Polonya'),
	(165, 'PT', 'Portekiz'),
	(166, 'PR', 'Porto Riko (US)'),
	(167, 'RE', 'Réunion (FR)'),
	(168, 'RO', 'Romanya'),
	(169, 'RW', 'Ruanda'),
	(170, 'RU', 'Rusya'),
	(171, 'BL', 'Saint Barthélemy (FR)'),
	(172, 'KN', 'Saint Kitts ve Nevis'),
	(173, 'LC', 'Saint Lucia'),
	(174, 'PM', 'Saint Pierre ve Miquelon (FR)'),
	(175, 'VC', 'Saint Vincent ve Grenadinler'),
	(176, 'WS', 'Samoa'),
	(177, 'SM', 'San Marino'),
	(178, 'ST', 'São Tomé ve Príncipe'),
	(179, 'SN', 'Senegal'),
	(180, 'SC', 'Seyseller'),
	(181, 'SL', 'Sierra Leone'),
	(182, 'CL', 'Sili'),
	(183, 'SG', 'Singapur'),
	(184, 'RS', 'Sirbistan'),
	(185, 'SK', 'Slovakya Cumhuriyeti'),
	(186, 'SI', 'Slovenya'),
	(187, 'SB', 'Solomon Adalari'),
	(188, 'SO', 'Somali'),
	(189, 'SS', 'South Sudan'),
	(190, 'SJ', 'Spitsbergen (NO)'),
	(191, 'LK', 'Sri Lanka'),
	(192, 'SD', 'Sudan'),
	(193, 'SR', 'Surinam'),
	(194, 'SY', 'Suriye'),
	(195, 'SA', 'Suudi Arabistan'),
	(196, 'SZ', 'Svaziland'),
	(197, 'TJ', 'Tacikistan'),
	(198, 'TZ', 'Tanzanya'),
	(199, 'TH', 'Tayland'),
	(200, 'TW', 'Tayvan'),
	(201, 'TG', 'Togo'),
	(202, 'TO', 'Tonga'),
	(203, 'TT', 'Trinidad ve Tobago'),
	(204, 'TN', 'Tunus'),
	(205, 'TR', 'Türkiye'),
	(206, 'TM', 'Türkmenistan'),
	(207, 'TC', 'Turks ve Caicos'),
	(208, 'TV', 'Tuvalu'),
	(209, 'UG', 'Uganda'),
	(210, 'UA', 'Ukrayna'),
	(211, 'OM', 'Umman'),
	(212, 'JO', 'Ürdün'),
	(213, 'UY', 'Uruguay'),
	(214, 'VU', 'Vanuatu'),
	(215, 'VA', 'Vatikan'),
	(216, 'VE', 'Venezuela'),
	(217, 'VN', 'Vietnam'),
	(218, 'WF', 'Wallis ve Futuna (FR)'),
	(219, 'YE', 'Yemen'),
	(220, 'NC', 'Yeni Kaledonya (FR)'),
	(221, 'NZ', 'Yeni Zelanda'),
	(222, 'CV', 'Yesil Burun Adalari'),
	(223, 'GR', 'Yunanistan'),
	(224, 'ZM', 'Zambiya'),
	(225, 'AF', 'Afganistan'),
	(226, 'ZW', 'Zimbabve');


--
-- Data for Name: urun_resimleri; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: urunler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.urunler VALUES
	(27, 'ürün onbeş', 10, 20, 30, 40, 50, 'asd', 100),
	(30, 'ürün onbeş', NULL, NULL, NULL, NULL, NULL, NULL, 100),
	(20, 'ürün bir', 0, 5, 10, 15, 20, 'asd', 100),
	(31, 'ürün dört', NULL, NULL, NULL, NULL, NULL, NULL, 100),
	(34, 'ürün iki', NULL, NULL, NULL, NULL, NULL, NULL, 95),
	(25, 'ürün onbeş', 10, 20, 30, 40, 50, 'asd', 98),
	(33, 'ürün onbeş', NULL, NULL, NULL, NULL, NULL, NULL, 98);


--
-- Data for Name: yetkiler; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: areas_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.areas_seq', 2438, false);


--
-- Name: cities_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cities_seq', 82, false);


--
-- Name: counties_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.counties_seq', 971, false);


--
-- Name: countries_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.countries_seq', 233, false);


--
-- Name: fatura_fatura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fatura_fatura_id_seq', 1, false);


--
-- Name: ilce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ilce_id_seq', 994, true);


--
-- Name: kategori_kategori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kategori_kategori_id_seq', 6, true);


--
-- Name: kisiler_kisi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kisiler_kisi_id_seq', 54, true);


--
-- Name: kullanici_grobu_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kullanici_grobu_group_id_seq', 1, false);


--
-- Name: kullanici_yetkileri_yetki_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kullanici_yetkileri_yetki_id_seq', 1, false);


--
-- Name: log_index_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_index_id_seq', 22, true);


--
-- Name: log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_log_id_seq', 1, false);


--
-- Name: musteri_adres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.musteri_adres_id_seq', 1, false);


--
-- Name: neighborhoods_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.neighborhoods_seq', 74914, false);


--
-- Name: sehir_index_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sehir_index_id_seq', 3707, true);


--
-- Name: siparis_detay_siparis_detay_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.siparis_detay_siparis_detay_id_seq', 4, true);


--
-- Name: siparisler_siparis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.siparisler_siparis_id_seq', 221, true);


--
-- Name: taksit_taksit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taksit_taksit_id_seq', 1, false);


--
-- Name: ulke_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ulke_id_seq', 226, true);


--
-- Name: urun_detay_urun_detay_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.urun_detay_urun_detay_id_seq', 1, false);


--
-- Name: urunler_urun_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.urunler_urun_id_seq', 34, true);


--
-- Name: yetkiler_yetki_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.yetkiler_yetki_id_seq', 1, false);


--
-- Name: fatura fatura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fatura
    ADD CONSTRAINT fatura_pkey PRIMARY KEY (fatura_id);


--
-- Name: ilce ilce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce
    ADD CONSTRAINT ilce_pkey PRIMARY KEY (ilce_id);


--
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (kategori_id);


--
-- Name: kisiler kisiler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisiler
    ADD CONSTRAINT kisiler_pkey PRIMARY KEY (kisi_id);


--
-- Name: kullanici_grubu kullanici_grubu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_grubu
    ADD CONSTRAINT kullanici_grubu_pkey PRIMARY KEY (group_id);


--
-- Name: kullanici_yetkileri kullanici_yetkileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_yetkileri
    ADD CONSTRAINT kullanici_yetkileri_pkey PRIMARY KEY (yetki_id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (log_id);


--
-- Name: kisi_adres musteri_adres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisi_adres
    ADD CONSTRAINT musteri_adres_pkey PRIMARY KEY (id);


--
-- Name: musteri2 musteri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri2
    ADD CONSTRAINT musteri_pkey PRIMARY KEY (musteri_no);


--
-- Name: sehir sehir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sehir
    ADD CONSTRAINT sehir_pkey PRIMARY KEY (sehir_id);


--
-- Name: siparis_detay siparis_detay_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis_detay
    ADD CONSTRAINT siparis_detay_pkey PRIMARY KEY (siparis_detay_id);


--
-- Name: siparisler siparisler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisler
    ADD CONSTRAINT siparisler_pkey PRIMARY KEY (siparis_id);


--
-- Name: taksit taksit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taksit
    ADD CONSTRAINT taksit_pkey PRIMARY KEY (taksit_id);


--
-- Name: ulke ulke_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ulke
    ADD CONSTRAINT ulke_pkey PRIMARY KEY (ulke_id);


--
-- Name: urun_resimleri urun_detay_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun_resimleri
    ADD CONSTRAINT urun_detay_pkey PRIMARY KEY (urun_resim_id);


--
-- Name: urunler urunler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urunler
    ADD CONSTRAINT urunler_pkey PRIMARY KEY (urun_id);


--
-- Name: yetkiler yetkiler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yetkiler
    ADD CONSTRAINT yetkiler_pkey PRIMARY KEY (yetki_id);


--
-- Name: urunler trigger_delete_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_delete_log AFTER DELETE ON public.urunler FOR EACH ROW EXECUTE FUNCTION public.process_log_after_delete();


--
-- Name: urunler trigger_insert_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_insert_log AFTER INSERT ON public.urunler FOR EACH ROW EXECUTE FUNCTION public.process_log_after_insert();


--
-- Name: musteri2 trigger_insert_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_insert_log AFTER INSERT ON public.musteri2 FOR EACH ROW EXECUTE FUNCTION public.process_log_after_insert();


--
-- Name: siparis_detay trigger_stoktan_dus; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_stoktan_dus AFTER INSERT ON public.siparis_detay FOR EACH ROW EXECUTE FUNCTION public.stoktan_dus();


--
-- Name: urunler trigger_update_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_log AFTER UPDATE ON public.urunler FOR EACH ROW EXECUTE FUNCTION public.process_log_after_update();


--
-- Name: musteri kisilerMusteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT "kisilerMusteri" FOREIGN KEY (kisi_id) REFERENCES public.kisiler(kisi_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kullanicilar kullaniciKisiler; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanicilar
    ADD CONSTRAINT "kullaniciKisiler" FOREIGN KEY (kisi_id) REFERENCES public.kisiler(kisi_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

