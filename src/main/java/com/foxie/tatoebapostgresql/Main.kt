package com.foxie.tatoebapostgresql

import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import org.apache.commons.compress.compressors.bzip2.BZip2CompressorInputStream
import org.postgresql.copy.CopyManager
import org.postgresql.core.BaseConnection
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.URL
import java.sql.DriverManager

class Main

fun main() {
    println("Enter the IP of your server")
    val ip = readLine()

    println("Enter the target database name")
    val database = readLine()

    println("Enter the username")
    val username = readLine()

    println("Enter the password")
    val password = readLine()

    println("Downloading and decompressing sentences...")
    if (!File("sentences.csv").exists())
        FileOutputStream("sentences.csv")
                .write(
                        downloadAndDecompress(URL("https://downloads.tatoeba.org/exports/sentences.tar.bz2"))
                                .readBytes()
                )

    println("Downloading and decompressing sentence links...")
    if (!File("links.csv").exists())
        FileOutputStream("links.csv")
                .write(
                        downloadAndDecompress(URL("https://downloads.tatoeba.org/exports/links.tar.bz2"))
                                .readBytes()
                )

    println("Downloading and decompressing audio info...")
    if (!File("audio.csv").exists())
        FileOutputStream("audio.csv")
                .write(
                        downloadAndDecompress(URL("https://downloads.tatoeba.org/exports/sentences_with_audio.tar.bz2"))
                                .readBytes()
                )

    println("Downloading and decompressing tag info...")
    if (!File("tags.csv").exists())
        FileOutputStream("tags.csv")
                .write(
                        downloadAndDecompress(URL("https://downloads.tatoeba.org/exports/tags.tar.bz2"))
                                .readBytes()
                )

    DriverManager
            .getConnection("jdbc:postgresql://$ip/$database", username, password)
            .use { connection ->
                println("Creating tables...")
                connection.createStatement().use {
                    it.execute(Main::class.java.getResource("/tables.sql").readText())
                }

                val copy = CopyManager(connection as BaseConnection)

                println("Inserting sentences...")
                println(
                        "Inserted " +
                                copy.copyIn(
                                        "COPY sentences(id, lang, sentence) FROM STDIN",
                                        FileInputStream("sentences.csv")
                                ) +
                                " rows into sentences table"
                )

                println("Inserting sentence links...")
                println(
                        "Inserted " +
                                copy.copyIn(
                                        "COPY links FROM STDIN",
                                        FileInputStream("links.csv")
                                ) +
                                " rows into links table"
                )

                println("Inserting audio info...")
                println(
                        "Inserted " +
                                copy.copyIn(
                                        "COPY audio FROM STDIN",
                                        FileInputStream("audio.csv")
                                ) +
                                " rows into temporary audio table"
                )

                println("Inserting tags...")
                println(
                        "Inserted " +
                                copy.copyIn(
                                        "COPY tags FROM STDIN",
                                        FileInputStream("tags.csv")
                                ) +
                                " rows into tags table"
                )

                println("Creating indices...")
                connection.createStatement().use {
                    it.execute(Main::class.java.getResource("/indices.sql").readText())
                }
            }

    println("Done!")
}

fun downloadAndDecompress(url: URL): TarArchiveInputStream {
    val archive = TarArchiveInputStream(BZip2CompressorInputStream(url.openStream()))
    archive.nextTarEntry
    return archive
}