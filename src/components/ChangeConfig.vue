<template>
  <v-container class="fill-height">

        <div v-if="noconfig">
          <v-row>
            <v-col>
              It looks like you have not set a pyimi server yet.  Please set one.
            </v-col>
          </v-row>

          <v-row>
            <v-col>
              <v-text-field label="Server"
                :rules="server_name_rules"
                hide-details="auto"
                v-model="inputed_srv_name">
              </v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-btn
                @click="apply_srv_name()"
                color="primary"
                large>
                Save
              </v-btn>        
              
            </v-col>
          </v-row>
        </div>
        <div v-else class="fullwidth">


          <v-row justify="center">

            <v-col>
              <div class="mycenter mb-4">
                Unit ID: {{unitid}}
              
              </div>
            </v-col>

          </v-row>
          <v-row justify="center">

              <v-col> 
              <v-list-item-group class="mb-4 "
              v-model="chosen_directory"
              >
                <v-list-item
                  v-for="(directory, index) in directories"
                  :key="index">
                  <template v-slot:default="{ active, toggle }">
                    <v-list-item-action>
                      <v-checkbox
                        v-model="active"
                        color="primary"
                        @click="toggle"
                      ></v-checkbox>
                    </v-list-item-action>

                    <v-list-item-content>
                      <v-list-item-title>{{directory}}</v-list-item-title>
                    </v-list-item-content>
                  </template>
                </v-list-item>

              </v-list-item-group>

              </v-col>
          </v-row>
          <v-row justify="center">

            <v-col>
              <div class="mycenter">
                <v-btn
                  @click="apply_config()"
                  color="primary"
                  large>
                  Change Configuration
                </v-btn>        
              </div>
            </v-col>
          </v-row>



        </div>
  </v-container>
</template>

<script>
  import axios from 'axios'
  const fs = require('fs')
  const exec = require('child_process').exec

  const homedir = require('os').homedir();

  function execute(command, callback) {
    exec(command, (error, stdout, stderr) => { 
    callback(stdout); 
  })};

  export default {
    
    mounted() {
        var stats = fs.stat(homedir + '/.config/IMI_Config_Changer.json', (err, stat) => {
          console.log("stat is", stat)
          console.log("is file", stat.isFile())
          console.log("is sym link", stat.isSymbolicLink())
          console.log("size", stat.length)
          if (stat && (stat.isFile() || stat.isSymbolicLink()) && stat.size > 0) {

            this.fetch_directories();

          } else {
            this.noconfig = true
          }
        });


    },

    methods: {

      fetch_directories () {

          let config_file_parsed = ''

          config_file_parsed = JSON.parse(fs.readFileSync(homedir + '/.config/IMI_Config_Changer.json'))
          this.pyimi_server = config_file_parsed.server

          execute('get_unit_id', (output) => {

            this.unitid = output
            axios.get(
                'http://' + this.pyimi_server + '/directory/' + this.unitid
            ).then(response => {
                this.dir_on_start = response.data

                axios.get(
                    'http://' + this.pyimi_server + '/directories'
                ).then(response => {
                  for (var i=0; i<response.data.length; i++) {
                    this.directories.push(response.data[i])
                    if (response.data[i] == this.dir_on_start) {
                      this.chosen_directory = i
                    }
                  }
                })


              }          
            )
          })
      },

      apply_srv_name () {
        console.log("apply hit")
        this.pyimi_server = {'server': this.inputed_srv_name}
        let json_to_write = JSON.stringify(this.pyimi_server)
        fs.writeFileSync(homedir + '/.config/IMI_Config_Changer.json', json_to_write)
        this.fetch_directories();
        this.noconfig = false;
      },

      apply_config() {

        axios.put(
            encodeURI('http://' + this.pyimi_server + '/directory/' + this.directories[this.chosen_directory]),
            {unitid: this.unitid},
            {headers: {"Content-Type": "application/json"}}
        ).then(response => {
            console.log("response.data")
        })
      }

    },

    data: () => ({
      pyimi_server: '',
      noconfig: false,
      inputed_srv_name: '',
      server_name_rules: [
        value => !!value || 'Required.',
      ],           
      dir_on_start: '',
      unitid: '',
      directories: [],
      chosen_directory: 0,


      
    }),
  }
</script>

<style scoped>
.mycenter {
  text-align: center;
}
.fullwidth {
  width: 100%;
}
</style>