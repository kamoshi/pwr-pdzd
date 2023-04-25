use std::collections::HashSet;
use std::convert::identity;
use std::error::Error;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use flate2::read::GzDecoder;
use regex::Regex;


type Err = Box<dyn Error>;

const PATH_EDITIONS: &str = "../docker/editions.txt";
const PATH_AUTHORS: &str = "../docker/authors.txt";
const PATH_WORKS: &str = "../docker/works.txt";
const PATH_GZ_AUTHORS: &str = "../data/authors.txt.gz";
const PATH_GZ_WORKS: &str = "../data/works.txt.gz";


fn collect_ids(regex_a: &Regex, regex_w: &Regex, path: &str) -> Result<(HashSet<String>, HashSet<String>), Err> {
    let mut a = HashSet::new();
    let mut w = HashSet::new();

    fn insert(regex: &Regex, destination: &mut HashSet<String>, line: &str) {
        if let Some(captures) = regex.captures(&line) {
            for id in captures.iter().skip(1).filter_map(identity) {
                destination.insert(id.as_str().into());
            };
        }
    }

    let file = File::open(path).unwrap();
    for line in BufReader::new(file).lines() {
        let line = line?;
        insert(&regex_a, &mut a, &line);
        insert(&regex_w, &mut w, &line);
    }
    Ok((a, w))
}

fn filter_stream(regex: &Regex, a: &HashSet<String>, i: &str, o: &str) -> Result<(), Err> {
    let i = File::open(i).unwrap();
    let mut o = File::create(o).unwrap();

    let reader = BufReader::new(GzDecoder::new(i));
    for line in reader.lines() {
        let line = line?;
        if let Some(captures) = regex.captures(&line) {
            if let Some(m) = captures.get(1) {
                if a.contains(m.as_str()) {
                    let json = line.rsplit_once("\t").unwrap().1;
                    write!(o, "{}\n", json)?;
                }
            }
        }
    }
    Ok(())
}


fn main() -> Result<(), Err> {
    let regex_a: Regex = Regex::new(r#""(/authors/[^"]+)""#).unwrap();
    let regex_w: Regex = Regex::new(r#""(/works/[^"]+)""#).unwrap();

    let (a, w) = collect_ids(&regex_a, &regex_w, PATH_EDITIONS)?;
    filter_stream(&regex_a, &a, PATH_GZ_AUTHORS, PATH_AUTHORS)?;
    filter_stream(&regex_w, &w, PATH_GZ_WORKS, PATH_WORKS)?;
    Ok(())
}
