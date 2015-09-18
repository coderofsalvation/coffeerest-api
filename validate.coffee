module.exports = {
  type: "object"
  required: ['host','resources','replyschema']
  properties:
    host:
      type: 'string'
    resources:
      type: 'object'
      properties:
        "^[0-9a-z:\/_\*\?]+$":
          type: 'object'
          properties:
            "/(get|post|del|put)/":
              type: 'object'
              required: ['description','function']
              properties:
                description:
                  type: 'string'
                function:
                  type: 'string'
                payload:
                  type: 'object'
                  properties:
                    "/[a-z_]+/":
                      type: 'object'
                      required: ['default','type']
                      properties:
                        default: 
                          type: 'string'
                        type:
                          type: 'string'
                          enum: ['string','integer','number','boolean','float','array','object']

    replyschema:
      type: 'object'
      required: ['type','required','messages','payload']
      properties:
        type:
          type: 'string'
        required:
          type: 'array'
          items: [{ type: 'string' }]
        messages:
          type: 'object'
          required: ['0','1','2','3','4']
          properties:
            0: { type: 'string' }
            1: { type: 'string' }
            2: { type: 'string' }
            3: { type: 'string' }
            4: { type: 'string' }
        payload:
          type: 'object'
          required: ['code','message','kind','data','errors']
          properties:
            code: { type: 'object' }
            message: { type: 'object' }
            kind: { type: 'object' }
            data: { type: 'object' }
            errors: { type: 'object' }
            



}
