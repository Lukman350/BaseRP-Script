-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 25 Mar 2021 pada 15.08
-- Versi server: 10.4.11-MariaDB
-- Versi PHP: 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `baserp`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `chars`
--

CREATE TABLE `chars` (
  `id` int(12) NOT NULL,
  `username` varchar(64) NOT NULL,
  `name` varchar(128) NOT NULL,
  `created` int(11) NOT NULL DEFAULT 0,
  `gender` int(11) NOT NULL,
  `origin` varchar(64) NOT NULL,
  `skin` int(24) NOT NULL,
  `world` int(24) NOT NULL DEFAULT 0,
  `interior` int(24) NOT NULL DEFAULT 0,
  `money` int(64) NOT NULL DEFAULT 250,
  `bankmoney` int(64) NOT NULL DEFAULT 500,
  `posx` float NOT NULL,
  `posy` float NOT NULL,
  `posz` float NOT NULL,
  `posa` float NOT NULL,
  `health` float NOT NULL,
  `armor` float NOT NULL,
  `level` int(12) NOT NULL DEFAULT 1,
  `logindate` int(24) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktur dari tabel `ucp`
--

CREATE TABLE `ucp` (
  `id` int(12) NOT NULL,
  `password` varchar(128) NOT NULL,
  `salt` varchar(128) NOT NULL,
  `username` varchar(64) NOT NULL,
  `email` varchar(64) NOT NULL,
  `admin` int(12) NOT NULL DEFAULT 0,
  `ip` varchar(24) NOT NULL DEFAULT '127.0.0.1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `chars`
--
ALTER TABLE `chars`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `ucp`
--
ALTER TABLE `ucp`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `chars`
--
ALTER TABLE `chars`
  MODIFY `id` int(12) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `ucp`
--
ALTER TABLE `ucp`
  MODIFY `id` int(12) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
