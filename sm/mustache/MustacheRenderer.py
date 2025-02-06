import os
import yaml
from argparse import ArgumentParser
from jinja2 import Template
import logging


def save_output(rendered_content, output_path):
    with open(output_path, 'w') as f:
        f.write(rendered_content)


def render_template(template, data):
    # Assuming data is a dictionary that matches the template's context
    rendered = template.render(**data)
    return rendered


class MustacheRenderer:
    def __init__(self):
        self.args = None

    def parse_args(self, args=None):
        parser = ArgumentParser(description='Render Jinja templates to output files')
        parser.add_argument('--template-path', dest='template_path',
                            required=True, help='Path to the template file')
        parser.add_argument('--value-path', dest='value_path',
                            required=True, help='Path to the input data file (e.g., JSON)')
        parser.add_argument('--output-path', dest='output_path',
                            required=True, help='Output path for rendered results')
        self.args = parser.parse_args(args=args)

    def load_template(self):
        # Build an absolute path to the template file
        template_full_path = os.path.join(os.getcwd(), self.args.template_path)
        with open(template_full_path, 'r') as f:
            # autoescape=False if you don't need HTML autoescaping
            return Template(f.read(), autoescape=True
                            )

    def run(self):
        try:
            logging.info("Starting rendering process")
            self.parse_args()

            # Load the Jinja2 template
            template = self.load_template()

            # Load data (assuming JSON format)
            value_full_path = os.path.join(os.getcwd(), self.args.value_path)
            try:
                with open(value_full_path, 'r') as f:
                    data = yaml.safe_load(f)
                logging.info(f"Successfully loaded {self.args.value_path}")
            except FileNotFoundError:
                raise Exception(f"Could not find input file at {self.args.value_path}")

            # Render template with data
            rendered_content = render_template(template, data)

            # Save output
            output_full_path = os.path.join(os.getcwd(), self.args.output_path)
            save_output(rendered_content, output_full_path)
            logging.info(f"Saved rendered content to {output_full_path}")

        except Exception as e:
            logging.error(f"An error occurred: {str(e)}", exc_info=True)
            raise  # Re-raise the exception to preserve the original traceback


def main():
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)  # Set the log level
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler = logging.StreamHandler()  # For console output
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    renderer = MustacheRenderer()
    renderer.run()


if __name__ == "__main__":
    main()
