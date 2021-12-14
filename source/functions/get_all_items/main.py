"""
Hakee kaikki tuotteet tietokannasta:
    http-GET -> funktio -> json

entrypoint: get_all_items
runtime: python39
"""


import psycopg2
import logging
import requests
import json


def get_all_items(request):
   
    con = None

    # TODO: käsittele "request" ja palauta joko 200 onnistuneesta vastauksesta http-pyyntöön
    #       tai virhekoodi (varmaan 500 tjsp ?)

    # TODO: Secret Manager -koodi -> vois tehdä oman funktion?

    try:
        con = psycopg2.connect(database="<HAE SECRETISTÄ>", user = "<HAE SECRETISTÄ>", password = "<HAE SECRETISTÄ>", host = "<HAE SECRETISTÄ>")
        cursor = con.cursor()

        SQL = 'SELECT * FROM <TAULUN NIMI TÄHÄN>;'
        cursor.execute(SQL)
        
        results = cursor.fetchall()
        
        # TODO: käsittele results, paitsi jos tulee valmiiksi json-muodossa -> return
        for line in results:
            pass
        
        cursor.close()
        
        return all_items_json

    # TODO: poikkeusten käsittely + loggaushommat
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

    finally:
        if con is not None:
            con.close()


def get_secrets():
    pass