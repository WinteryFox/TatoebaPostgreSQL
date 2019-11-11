package com.foxie.tatoebapostgresql

import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import org.apache.commons.compress.compressors.bzip2.BZip2CompressorInputStream
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
    val password = System.console()?.readPassword() ?: readLine()

    DriverManager
            .getConnection("jdbc:postgresql://$ip/$database?user=$username&password=$password")
            .use { connection ->
                println("Creating tables...")
                connection.createStatement().use {
                    it.execute(Main::class.java.getResource("/tables.sql").readText())
                }

                connection.autoCommit = false

                println("Downloading and inserting sentences...")
                connection.prepareStatement("INSERT INTO sentences (id, lang, sentence) VALUES (?, ?, ?)")
                        .use {
                            downloadAndDecompress(URL("https://downloads.tatoeba.org/exports/sentences.tar.bz2"))
                                    .use { stream ->
                                        stream
                                        .bufferedReader()
                                            .forEachLine { line ->
                                                val parts = line.split("\t")

                                                it.setInt(1, parts[0].toInt())
                                                it.setString(2, parts[1])
                                                it.setString(3, parts[2])
                                                it.addBatch()
                                            }
                                    }

                            it.executeBatch()
                            connection.commit()
                        }
            }

    // https://jdbc.postgresql.org/documentation/publicapi/org/postgresql/copy/CopyManager.html

    println("Done!")
}

fun downloadAndDecompress(url: URL): TarArchiveInputStream {
    val archive = TarArchiveInputStream(BZip2CompressorInputStream(url.openStream()))
    archive.nextTarEntry
    return archive
}